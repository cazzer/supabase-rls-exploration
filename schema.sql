create extension if not exists "uuid-ossp";

create table items (
  id uuid not null primary key
);
alter table items enable row level security;

create table item_permissions (
  id uuid not null primary key,
  item_id uuid references items(id) on delete cascade,
  permitted uuid not null primary key
);
alter table item_permissions enable row level security;

create or replace function insert_permission()
  returns trigger
  as $$
begin
  insert into item_permissions (item_id, permitted_id) values (
    new.id,
    auth.uid()
  );
  return new;
end
$$ language plpgsql;

create trigger insert_permission_trigger
after insert
on items
for each row
execute procedure insert_permission();

create policy manage_item
on items
for all
using (
  exists(
    select item_id
    from permissions
    where items.id = item_id
    and permitted_id = auth.uid()
  )
)
with check (
  exists(
    select item_id
    from permissions
    where items.id = item_id
    and permitted_id = auth.uid()
  )
);

create policy insert_items
on items
for insert
with check (true);

create policy return_new_item
on items
for select
using (
  not exists(
    select item_id
    from permissions
    where item_id = items.id
  )
);

create policy manage_permissions
on item_permissions
for all
using (
  permitted_id = auth.uid()
)
with check (
  permitted_id = auth.uid()
);
