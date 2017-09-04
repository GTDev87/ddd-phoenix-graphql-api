defmodule App.Post.Projectors.Post do
  use Commanded.Projections.Ecto, name: "App.Post.Projectors.Post"

  alias App.Post.Events.PostCreated

  project %PostCreated{} = created do

    created_map = Map.from_struct(created)

    # %App.Post.Post{}
    # |> App.Post.Post.changeset(created_map)
    # |> App.WriteRepo.insert()

    Ecto.Multi.insert(multi, :post, struct(App.Post.Post, created_map))
  end
end
