begin;

select plan(6);

SET SESSION "test.public_item_id" = '82a261ea-5c6c-45b4-b5dd-dd0804dd10f2';
SET SESSION "test.private_item_id" = '82a261ea-5c6c-45b4-b5dd-dd0804dd10f1';

-- user A, item creator
select tests.create_supabase_user('user_a');
select tests.authenticate_as('user_a');

select results_eq(
  $$
    insert into items (id, content, public) values
    (current_setting('test.private_item_id')::uuid, 'test', false)
    returning id
  $$,
  array[current_setting('test.private_item_id')::uuid],
  'user A can insert private item A'
);

select results_eq(
  $$
    insert into items (id, content, public) values
    (current_setting('test.public_item_id')::uuid, 'test', true)
    returning id
  $$,
  array[current_setting('test.public_item_id')::uuid],
  'user A can insert public item A'
);

select results_eq(
  $$
    select id from items
  $$,
  array[
    current_setting('test.private_item_id')::uuid,
    current_setting('test.public_item_id')::uuid
  ],
  'user A can select both items'
);

-- user B, item selector
select tests.create_supabase_user('user_b');
select tests.authenticate_as('user_b');

select results_eq(
  $$
    select content from items
    where id = current_setting('test.private_item_id')::uuid
  $$,
  array[]::text[],
  'user B can''t select the private item'
);

select results_eq(
  $$
    select id from items
    where id = current_setting('test.public_item_id')::uuid
  $$,
  array[current_setting('test.public_item_id')]::uuid[],
  'user B can select the public item'
);

select results_eq(
  $$
    update items set public = false
    where id = current_setting('test.public_item_id')::uuid
    returning id
  $$,
  array[]::uuid[],
  'user B can''t update the public item'
);

select * from finish();
rollback;
