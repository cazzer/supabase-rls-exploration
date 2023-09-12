create extension if not exists "uuid-ossp";

CREATE TABLE items (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    content text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    metadata jsonb DEFAULT '{}'::jsonb
);
alter table items enable row level security;

CREATE TABLE item_permissions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id uuid REFERENCES items(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    permitted_id uuid NOT NULL
);
alter table item_permissions enable row level security;

create policy manage_item
on items
for all
using (
  exists(
    select item_id
    from item_permissions
    where items.id = item_id
    and permitted_id = current_setting('bd.user_id')::uuid
  )
)
with check (
  exists(
    select item_id
    from item_permissions
    where items.id = item_id
    and permitted_id = current_setting('bd.user_id')::uuid
  )
);

create policy insert_items
on items
for insert
with check (true);

create or replace function insert_permission()
  returns trigger
  security definer
  as $$
begin
  insert into item_permissions (item_id, permitted_id) values (
    new.id,
    current_setting('bd.user_id')::uuid
  );
  return new;
end
$$ language plpgsql;

create trigger insert_permission_trigger
after insert
on items
for each row
execute procedure insert_permission();


create policy insert_item_permission_for_new_item
on item_permissions
for insert
using (
  permitted_id = current_setting('bd.user_id')::uuid
)
with check (
  not exists(
    select true
    from item_permissions
    where item_id = item_id
  )
);

create policy select_item_permissions
on item_permissions
for select
using (
  permitted_id = current_setting('bd.user_id')::uuid
);

create policy delete_item_permissions
on item_permissions
for delete
using (
  permitted_id = current_setting('bd.user_id')::uuid
);

