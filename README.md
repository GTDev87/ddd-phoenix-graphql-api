# Jwt Token Server
* Phoenix
* GraphQL
* PostgreSQL

# About
This is an authentication server that retruns jwts handles 3rd party OAUTH delegation.

# Running the app:

Apart from cloning the repository, you will have to install any missing tools such as, mix, PostgreSQL, etc.

To start the app run the following:
  * Install Mix dependencies with `mix deps.get`
  * Run PostgreSQL in the terminal with `psql` and run `CREATE USER postgres SUPERUSER;`
  * Create PostgreSQL database `app-dev` with Phoenix Ecto, run `mix ecto.create`
  * Create required tables `mix ecto.migrate`
  * Optionally populate tables with `mix run priv/repo/seeds.exs`
  * Start Phoenix endpoint with `mix phoenix.server`

App is now running on `localhost:4000`
Explore the GraphQL database using its graphical interface at `localhost:4000/graphiql`

## Some of the used frameworks
* [phoenix-ecto](https://github.com/phoenixframework/phoenix_ecto)
* [absinthe-graphql](http://absinthe-graphql.org/guides/plug-phoenix/)

## Learn more
* http://elm-lang.org/
* Official website: http://www.phoenixframework.org/
* Guides: http://phoenixframework.org/docs/overview
* Docs: http://hexdocs.pm/phoenix
* Mailing list: http://groups.google.com/group/phoenix-talk
* Source: https://github.com/phoenixframework/phoenix
