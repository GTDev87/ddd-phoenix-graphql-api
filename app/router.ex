defmodule App.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  forward "/api", Absinthe.Plug,
    schema: App.Schema

  forward "/graphiql", Absinthe.Plug.GraphiQL,
    schema: App.Schema

  # Other scopes may use custom stacks.
  # scope "/api", App do
  #   pipe_through :api
  # end
end
