defmodule App.Post.Projectors.Post do
  use Commanded.Projections.Ecto, name: "App.Post.Projectors.Post"

  alias App.Post.Events.PostCreated

  def after_update(_event, _metadata, changes), do: App.Notifications.publish_changes(changes)

  project %PostCreated{} = created do
    created_map = Map.from_struct(created)
    multi
    |> Ecto.Multi.insert(:post, struct(App.Post.Post, created_map))
  end
end
