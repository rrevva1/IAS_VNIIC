#!/usr/bin/env python3
"""Copy missing rows from reference DB into target DB (by primary key). Does not delete or update."""

from __future__ import annotations

import os
import sys

import psycopg2
from psycopg2 import sql
from psycopg2.extras import execute_values

CONN = dict(
    host=os.environ.get("DB_HOST", "localhost"),
    port=int(os.environ.get("DB_PORT", "5432")),
    user=os.environ.get("DB_USER", "postgres"),
    password=os.environ.get("DB_PASSWORD", "12345"),
)

TARGET_DB = os.environ.get("DB_NAME", "ias_vniic")
REF_DB = os.environ.get("REF_DB_NAME", "ias_vniic_dump_ref")
SCHEMA = "tech_accounting"

# Tables with composite PK or no simple id PK — handle explicitly if needed.
SKIP_TABLES = {"migration"}


def get_tables(conn) -> list[str]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = %s AND table_type = 'BASE TABLE'
            ORDER BY table_name
            """,
            (SCHEMA,),
        )
        return [r[0] for r in cur.fetchall() if r[0] not in SKIP_TABLES]


def get_pk_columns(conn, table: str) -> list[str]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT a.attname
            FROM pg_index i
            JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey)
            JOIN pg_class c ON c.oid = i.indrelid
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE i.indisprimary
              AND n.nspname = %s
              AND c.relname = %s
            ORDER BY array_position(i.indkey, a.attnum)
            """,
            (SCHEMA, table),
        )
        cols = [r[0] for r in cur.fetchall()]
    return cols


def get_columns(conn, table: str) -> list[str]:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s
            ORDER BY ordinal_position
            """,
            (SCHEMA, table),
        )
        return [r[0] for r in cur.fetchall()]


def sync_table(target, ref, table: str) -> int:
    pk_cols = get_pk_columns(target, table)
    if not pk_cols:
        print(f"  skip {table}: no primary key")
        return 0

    target_cols = get_columns(target, table)
    ref_cols = get_columns(ref, table)
    cols = [c for c in target_cols if c in ref_cols]
    if not cols:
        print(f"  skip {table}: no common columns")
        return 0

    pk_pred = sql.SQL(" AND ").join(
        sql.SQL("t.{col} = r.{col}").format(col=sql.Identifier(c)) for c in pk_cols
    )
    col_idents = sql.SQL(", ").join(sql.Identifier(c) for c in cols)
    select_list = sql.SQL(", ").join(sql.SQL("r.{c}").format(c=sql.Identifier(c)) for c in cols)

    query = sql.SQL(
        """
        INSERT INTO {schema}.{table} ({cols})
        SELECT {select_list}
        FROM dblink(%s, %s) AS r ({col_defs})
        WHERE NOT EXISTS (
            SELECT 1 FROM {schema}.{table} t WHERE {pk_pred}
        )
        """
    ).format(
        schema=sql.Identifier(SCHEMA),
        table=sql.Identifier(table),
        cols=col_idents,
        select_list=select_list,
        col_defs=sql.SQL(", ").join(
            sql.SQL("{c} {t}").format(c=sql.Identifier(c), t=sql.SQL(get_col_type(ref, table, c)))
            for c in cols
        ),
        pk_pred=pk_pred,
    )

    remote_sql = (
        f"SELECT {', '.join(cols)} FROM {SCHEMA}.{table}"
    )
    conninfo = (
        f"host={CONN['host']} port={CONN['port']} dbname={REF_DB} "
        f"user={CONN['user']} password={CONN['password']}"
    )

    with target.cursor() as cur:
        cur.execute("CREATE EXTENSION IF NOT EXISTS dblink")
        cur.execute(query, (conninfo, remote_sql))
        inserted = cur.rowcount
    target.commit()
    return inserted


def get_col_type(conn, table: str, column: str) -> str:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT data_type, udt_name, character_maximum_length, numeric_precision, numeric_scale
            FROM information_schema.columns
            WHERE table_schema = %s AND table_name = %s AND column_name = %s
            """,
            (SCHEMA, table, column),
        )
        row = cur.fetchone()
    if not row:
        return "text"
    data_type, udt_name, char_len, num_prec, num_scale = row
    if data_type == "USER-DEFINED":
        return udt_name
    if data_type == "character varying":
        return f"varchar({char_len})" if char_len else "varchar"
    if data_type == "character":
        return f"char({char_len})" if char_len else "char"
    if data_type == "numeric" and num_prec:
        return f"numeric({num_prec},{num_scale or 0})"
    mapping = {
        "bigint": "bigint",
        "integer": "integer",
        "smallint": "smallint",
        "boolean": "boolean",
        "text": "text",
        "date": "date",
        "jsonb": "jsonb",
        "inet": "inet",
        "timestamp with time zone": "timestamptz",
        "timestamp without time zone": "timestamp",
        "time without time zone": "time",
    }
    return mapping.get(data_type, "text")


def fix_sequences(conn) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT c.relname AS sequence_name,
                   t.relname AS table_name,
                   a.attname AS column_name
            FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            JOIN pg_depend d ON d.objid = c.oid AND d.deptype = 'a'
            JOIN pg_class t ON t.oid = d.refobjid
            JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
            WHERE c.relkind = 'S' AND n.nspname = %s
            """,
            (SCHEMA,),
        )
        for seq_name, table_name, col_name in cur.fetchall():
            cur.execute(
                sql.SQL(
                    "SELECT setval(%s, COALESCE((SELECT MAX({col}) FROM {schema}.{table}), 1), true)"
                ).format(
                    col=sql.Identifier(col_name),
                    schema=sql.Identifier(SCHEMA),
                    table=sql.Identifier(table_name),
                ),
                (f"{SCHEMA}.{seq_name}",),
            )
    conn.commit()


def main() -> int:
    target = psycopg2.connect(dbname=TARGET_DB, **CONN)
    ref = psycopg2.connect(dbname=REF_DB, **CONN)
    try:
        tables = get_tables(target)
        total = 0
        print(f"Syncing {len(tables)} tables from {REF_DB} -> {TARGET_DB}")
        for table in tables:
            try:
                n = sync_table(target, ref, table)
                if n:
                    print(f"  {table}: +{n}")
                total += n
            except Exception as exc:
                target.rollback()
                print(f"  {table}: ERROR {exc}", file=sys.stderr)
        print("Fixing sequences...")
        fix_sequences(target)
        print(f"Done. Inserted {total} rows total.")
    finally:
        target.close()
        ref.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
