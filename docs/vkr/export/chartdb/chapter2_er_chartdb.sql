-- ChartDB import SQL (logical schema for ER diagram)

create table users (
  id bigserial primary key,
  login varchar(100),
  full_name varchar(255),
  email varchar(255),
  is_blocked boolean default false
);

create table roles (
  id bigserial primary key,
  code varchar(100),
  name varchar(255)
);

create table permissions (
  id bigserial primary key,
  code varchar(100),
  name varchar(255)
);

create table user_roles (
  id bigserial primary key,
  user_id bigint not null references users(id),
  role_id bigint not null references roles(id)
);

create table role_permissions (
  id bigserial primary key,
  role_id bigint not null references roles(id),
  permission_id bigint not null references permissions(id)
);

create table locations (
  id bigserial primary key,
  name varchar(255),
  parent_id bigint references locations(id)
);

create table dic_equipment_status (
  id bigserial primary key,
  code varchar(50),
  name varchar(255)
);

create table dic_task_status (
  id bigserial primary key,
  code varchar(50),
  name varchar(255)
);

create table spr_parts (
  id bigserial primary key,
  name varchar(255)
);

create table spr_chars (
  id bigserial primary key,
  part_id bigint not null references spr_parts(id),
  name varchar(255)
);

create table equipment (
  id bigserial primary key,
  inventory_no varchar(100),
  serial_no varchar(100),
  name varchar(255),
  model varchar(255),
  location_id bigint not null references locations(id),
  responsible_user_id bigint not null references users(id),
  status_id bigint not null references dic_equipment_status(id),
  is_deleted boolean default false,
  is_archived boolean default false
);

create table equip_history (
  id bigserial primary key,
  equipment_id bigint not null references equipment(id),
  actor_id bigint not null references users(id),
  event_type varchar(100),
  event_at timestamptz,
  description text
);

create table part_char_values (
  id bigserial primary key,
  equipment_id bigint not null references equipment(id),
  part_id bigint not null references spr_parts(id),
  char_id bigint not null references spr_chars(id),
  value text
);

create table tasks (
  id bigserial primary key,
  requester_id bigint not null references users(id),
  executor_id bigint references users(id),
  status_id bigint not null references dic_task_status(id),
  title varchar(255),
  description text,
  created_at timestamptz,
  updated_at timestamptz
);

create table task_history (
  id bigserial primary key,
  task_id bigint not null references tasks(id),
  actor_id bigint not null references users(id),
  changed_at timestamptz,
  old_state text,
  new_state text
);

create table task_equipment (
  id bigserial primary key,
  task_id bigint not null references tasks(id),
  equipment_id bigint not null references equipment(id)
);

create table desk_attachments (
  id bigserial primary key,
  uploaded_by bigint not null references users(id),
  file_name varchar(255),
  mime_type varchar(120),
  size_bytes bigint,
  uploaded_at timestamptz
);

create table task_attachments (
  id bigserial primary key,
  task_id bigint not null references tasks(id),
  attachment_id bigint not null references desk_attachments(id)
);

create table inventory_runs (
  id bigserial primary key,
  location_id bigint not null references locations(id),
  responsible_user_id bigint not null references users(id),
  run_date timestamptz,
  status varchar(100)
);

create table inventory_items (
  id bigserial primary key,
  inventory_run_id bigint not null references inventory_runs(id),
  equipment_id bigint not null references equipment(id),
  fact_status varchar(100),
  discrepancy_type varchar(100),
  comment text
);

create table audit_events (
  id bigserial primary key,
  actor_id bigint not null references users(id),
  event_at timestamptz,
  object_type varchar(100),
  object_id bigint,
  result varchar(100)
);

create table import_runs (
  id bigserial primary key,
  started_at timestamptz,
  finished_at timestamptz,
  status varchar(100)
);

create table import_errors (
  id bigserial primary key,
  import_run_id bigint not null references import_runs(id),
  row_no int,
  error_text text
);
