create extension if not exists "uuid-ossp";

create TABLE
  items (
    id uuid default gen_random_uuid () primary key,
    content text,
    created_at timestamp with time zone not null default now(),
    public boolean not null default false,
    metadata jsonb default '{}'::jsonb
  );

alter table items enable row level security;

alter publication supabase_realtime
add table items;

create table
  item_permissions (
    id uuid default gen_random_uuid () primary key,
    item_id uuid references items (id) on delete cascade,
    permitted_id uuid not null
  );

alter table item_permissions enable row level security;

alter publication supabase_realtime
add table item_permissions;

-- allow all authenticated users to insert items
create policy insert_items on items for insert to authenticated
with
  check (true);

-- allow all authenticated users to select items that they just created
create policy select_item on items for
select
  to authenticated using (
    not exists (
      select
        *
      from
        item_permissions
      where
        item_id = items.id
    )
  );

-- allow authenticated users to do anything to items they have permission for
create policy manage_item on items for all to authenticated using (
  exists (
    select
      item_id
    from
      item_permissions
    where
      items.id = item_id
      and permitted_id = auth.uid ()
  )
)
with
  check (
    exists (
      select
        item_id
      from
        item_permissions
      where
        items.id = item_id
        and permitted_id = auth.uid ()
    )
  );

-- allow public users to select public items
create policy select_public_item on items for
select
  to public using (public = true);

create
or replace function insert_permission () returns trigger security definer as $$
begin
  insert into item_permissions (item_id, permitted_id) values (
    new.id,
    auth.uid()
  );
  return new;
end
$$ language plpgsql;

create trigger insert_permission_trigger
after insert on items for each row
execute procedure insert_permission ();

-- allow all authenticated users to select item permissions
create policy select_item_permissions on item_permissions for
select
  to authenticated using (true);

-- allow all authenticated users to insert item permissions
create policy insert_item_permissions on item_permissions for insert to authenticated
with
  check (
    exists (
      select
        id
      from
        item_permissions
      where
        item_id = item_id
        and permitted_id = auth.uid ()
    )
  );

-- allow all authenticated users to delete their own permissions
create policy delete_item_permissions on item_permissions for delete to authenticated using (permitted_id = auth.uid ());
