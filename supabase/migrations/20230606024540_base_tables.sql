create extension if not exists "uuid-ossp";

CREATE TABLE items (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    content text,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    metadata jsonb DEFAULT '{}'::jsonb
);
alter table items enable row level security;
alter publication supabase_realtime add table items;

CREATE TABLE item_permissions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id uuid REFERENCES items(id) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    permitted_id uuid NOT NULL
);
alter table item_permissions enable row level security;
alter publication supabase_realtime add table item_permissions;

create policy insert_items
on items
for insert
to authenticated
with check (true);

CREATE OR REPLACE FUNCTION volatilePermissionCheck(item_id uuid) RETURNS TABLE (id uuid) AS $$
    select id from item_permissions
    where item_permissions.item_id = item_id
    and permitted_id = auth.uid()
$$ LANGUAGE sql VOLATILE;

CREATE POLICY select_item
ON items
FOR SELECT
to authenticated
USING (
    NOT EXISTS (
      select *
      from item_permissions
      where item_id = items.id
    )
);

create policy manage_item
on items
for all
to authenticated
using (
  exists(
    select item_id
    from item_permissions
    where items.id = item_id
    and permitted_id = auth.uid()
  )
)
with check (
  exists(
    select item_id
    from item_permissions
    where items.id = item_id
    and permitted_id = auth.uid()
  )
);

create or replace function insert_permission()
  returns trigger
  security definer
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
before insert
on items
for each row
execute procedure insert_permission();

-- create policy insert_item_permission_for_new_item
-- on item_permissions
-- for insert
-- with check (
--   permitted_id = auth.uid()
--   and not exists(
--     select true
--     from item_permissions
--     where item_id = item_id
--   )
-- );

create policy select_item_permissions
on item_permissions
for select
to authenticated
using (
  true
);

create policy insert_item_permissions
on item_permissions
for insert
to authenticated
with check (
  exists (
    select id
    from item_permissions
    where item_id = item_id
    and permitted_id = auth.uid()
  )
);

create policy delete_item_permissions
on item_permissions
for delete
to authenticated
using (
  permitted_id = auth.uid()
);
