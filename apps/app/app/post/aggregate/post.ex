defmodule App.Post.Aggregate.Post do
  defstruct [
    uuid: nil,
    title: nil,
    body: nil,
    user: nil,
    user_name: nil,
  ]

  alias App.Post.Aggregate.Post
  alias App.Post.Commands.{CreatePost}
  alias App.Post.Events.{PostCreated}

  @doc """
  Publish an article
  """
  def execute(%Post{uuid: nil}, %CreatePost{} = create) do
    %PostCreated{
      uuid: create.uuid,
      title: create.title,
      body: create.body,
    }
  end
  # state mutators

  def apply(%Post{} = post, %PostCreated{} = created) do
    %Post{post |
      uuid: created.uuid,
      title: created.title,
      body: created.body,
      user: nil,
      user_name: nil,
    }
  end
end
