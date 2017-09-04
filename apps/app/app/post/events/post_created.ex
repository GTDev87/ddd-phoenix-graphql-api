defmodule App.Post.Events.PostCreated do
  @derive [Poison.Encoder]
  defstruct [
    :uuid,
    :title,
    :body,
  ]
end
