import json
import re
from pathlib import Path


TABLE_RE = re.compile(r"^Table\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")
PROJECT_RE = re.compile(r"^Project\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{")
REF_RE = re.compile(
    r"^Ref:\s*([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\s*>\s*([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)"
)
FIELD_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s+([A-Za-z0-9_()]+)(?:\s+\[(.+)\])?$")


def parse_dbml(path: Path) -> dict:
    lines = path.read_text(encoding="utf-8").splitlines()
    project_name = None
    tables = []
    refs = []
    in_project = False
    in_table = False
    current_table = None

    for raw in lines:
        line = raw.strip()
        if not line:
            continue

        if not in_table:
            m_project = PROJECT_RE.match(line)
            if m_project:
                project_name = m_project.group(1)
                in_project = True
                continue

        if in_project and line == "}":
            in_project = False
            continue

        if in_project and line.startswith("Note:"):
            note = line.split(":", 1)[1].strip().strip('"')
            continue

        if not in_table:
            m_table = TABLE_RE.match(line)
            if m_table:
                current_table = {"name": m_table.group(1), "columns": []}
                tables.append(current_table)
                in_table = True
                continue

        if in_table:
            if line == "}":
                in_table = False
                current_table = None
                continue

            m_field = FIELD_RE.match(line)
            if m_field and current_table is not None:
                col_name, col_type, constraints = m_field.groups()
                flags = []
                if constraints:
                    flags = [item.strip() for item in constraints.split(",")]
                current_table["columns"].append(
                    {
                        "name": col_name,
                        "type": col_type,
                        "constraints": flags,
                    }
                )
            continue

        m_ref = REF_RE.match(line)
        if m_ref:
            from_table, from_column, to_table, to_column = m_ref.groups()
            refs.append(
                {
                    "from": {"table": from_table, "column": from_column},
                    "to": {"table": to_table, "column": to_column},
                    "relation": "many_to_one",
                }
            )

    result = {
        "format": "chartdb-json-v1",
        "project": {
            "name": project_name or path.stem,
            "database_type": "PostgreSQL",
            "source": str(path.as_posix()),
        },
        "tables": tables,
        "references": refs,
    }
    if "note" in locals():
        result["project"]["note"] = note
    return result


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    chartdb_dir = root / "docs" / "vkr" / "export" / "chartdb"
    inputs = [
        chartdb_dir / "chapter2_er_chartdb.dbml",
        chartdb_dir / "chapter2_er_logical_chartdb.dbml",
    ]

    for src in inputs:
        data = parse_dbml(src)
        out_path = src.with_suffix(".json")
        out_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"Generated: {out_path}")


if __name__ == "__main__":
    main()
