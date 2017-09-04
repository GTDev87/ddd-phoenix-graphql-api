defmodule App.Post.Commands.CreatePost do
  defstruct [
    uuid: "",
    title: "",
    body: "",
  ]

  use ExConstructor

  alias App.Post.Commands.CreatePost

  def assign_uuid(%CreatePost{} = create_post, uuid) do
    %CreatePost{create_post | uuid: uuid}
  end
end
