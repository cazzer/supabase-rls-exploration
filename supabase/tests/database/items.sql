begin;

select plan(11);

select tests.create_supabase_user('user_a');
select tests.authenticate_as('user_a');

SET SESSION "test.item_a_id" = '82a261ea-5c6c-45b4-b5dd-dd0804dd10f1';

select results_eq(
  $$
    insert into items (id, content) values
    (current_setting('test.item_a_id')::uuid, 'test')
    returning id
  $$,
  array[current_setting('test.item_a_id')::uuid],
  'user A can insert item A'
);

select results_eq(
  $$
    select id from items
    where id = current_setting('test.item_a_id')::uuid
  $$,
  array[current_setting('test.item_a_id')::uuid],
  'user A can select item A'
);

-- item creator can updater their item
select lives_ok(
  $$
    update items set content = 'test2'
    where id = current_setting('test.item_a_id')::uuid
  $$,
  'user A can update item A'
);

select results_eq(
  $$
    select item_id from item_permissions
    where item_id = current_setting('test.item_a_id')::uuid
  $$,
  array[current_setting('test.item_a_id')::uuid],
  'user A can select item A permissions'
);

select tests.create_supabase_user('user_b');
select tests.authenticate_as('user_b');

select results_eq(
  $$
    select content from items
    where id = current_setting('test.item_a_id')::uuid
  $$,
  array[]::text[],
  'user B can''t select item A'
);

select results_eq(
  $$
    update items set content = 'test3'
    where id = current_setting('test.item_a_id')::uuid
    returning id
  $$,
  array[]::uuid[],
  'user B can''t update item A'
);

select results_eq(
  $$
    select item_id from item_permissions
    where item_id = current_setting('test.item_a_id')::uuid
  $$,
  array[current_setting('test.item_a_id')::uuid],
  'user B can select item A permissions'
);

select throws_ok(
  $$
    insert into item_permissions (item_id, permitted_id)
    values (current_setting('test.item_a_id')::uuid, tests.get_supabase_uid('user_b'))
    returning item_id
  $$,
  'new row violates row-level security policy for table "item_permissions"',
  'user B can''t insert item A permissions'
);

select tests.authenticate_as('user_a');

select results_eq(
  $$
    insert into item_permissions (item_id, permitted_id)
    values (current_setting('test.item_a_id')::uuid, tests.get_supabase_uid('user_b'))
    returning item_id
  $$,
  array[current_setting('test.item_a_id')::uuid],
  'user A can insert item A permissions'
);

select tests.authenticate_as('user_b');

select lives_ok(
  $$
    update items
    set content = 'test3'
    where id = current_setting('test.item_a_id')::uuid
  $$,
  'user B can now update item A'
);

select isnt_empty(
  $$
    select * from items
    where id = current_setting('test.item_a_id')::uuid
  $$,
  'user B can now select item A'
);


select * from finish();
rollback;
