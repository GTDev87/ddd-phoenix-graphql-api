defmodule Conduit.Router do
  use Commanded.Commands.Router

  alias App.Post.Aggregate.{Post}

  dispatch [App.Post.Commands.CreatePost], to: Post, identity: :uuid
end
