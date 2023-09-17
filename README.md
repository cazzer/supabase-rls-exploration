# Supabase RLS Exploration

There are two things going on here:

1. Supabase stack
2. Simple web app for visually testing the database (there are unit tests as well, so skip the web steps if you don't want to bother)

## Running Everything Locally

### Docker

All the batteries are included except for Docker; you've gotta do that part yourself. [Here's a link](https://www.docker.com/products/docker-desktop/) if need one. Once you have Docker installed and running, start the Supabase stack up locally with:

```
yarn start-db
```

After this starts up, take note of parameters that get dumped since you'll need them for the web stack if you plan to use that.

### .env

If you'd like to test visually, you will need the following variables set to make the magic happen, whether you run locally or in the cloud:

1. `REACT_APP_SUPABASE_URL`, which should be set to the `API URL` parameter for local development
2. `REACT_APP_SUPABASE_KEY`, which you can use the `anon key` parameter for locally

### Install deps

Again, this is just for the web stack:

```
yarn
```

### Run the web stack against the local supabase stack

Also just for the web stack:

```
yarn start-web-local
```

## Testing

### pgTap

Since I've literally got nothing better to do, I wrote a few test cases to validate the expected behavior. Give them a whirl with `yarn test-db` and make my day.

More on unit testing with Supabase is [in their docs](https://supabase.com/docs/guides/database/testing).

### Visually

![simple visual demo](https://github.com/cazzer/supabase-rls-exploration/assets/2466842/18c8318e-5d87-407a-ab93-d7bff879fd4e)

Ok this is what the web client is for, and that's it. So if you don't like the way it looks then know that I agree with you, I just wanted to visualize the behavior that those unit tests have already proven. But anyway, when you did the `start-local` it should've opened up your browser to `http://localhost:3000/` or something. Here is how to use that rather unsightly application:

1. "Sign Up", (remember this is just local, so I normally use `asdf@asdf.com` and `asdfasdf`). The Supabase stack will just validate that the email looks email-y and the password has at least six characters, neither of which will show as an error in the UI if you get it wrong
2. Now you're logged in. Note that if you refresh your session will be lost, but the same email/password combo will let you log back in
3. Click anywhere on the screen to create a happy little square. Drag it around if you want, I don't care
4. Open a new browser window and register a new account, (use a different email)
5. Click around and make some boxes for this person
6. Note that the people can't see each other's boxes
7. _Shift_ click on a box to make it _public_. This will give it a fancy border, and will make it show up for the other person, (along with any new accounts you register).
8. Now if you drag the public box around, (on the account that created it), it will move on the other persons screen
9. You can also try dragging it for the person that _didn't_ create it, and see that it won't move for the person who did create it, (and if you refresh the non-owner and re-login, see that it has moved back)
10. If at any point you get confused about who is who and want to blow everything away, run `yarn reset-db` to clear everything out
