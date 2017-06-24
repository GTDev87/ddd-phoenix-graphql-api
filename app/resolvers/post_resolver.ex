defmodule App.PostResolver do
  def all(_args, _info) do
    {:ok, App.Repo.all(App.Models.Post)}
  end

  def find(%{id: id}, _info) do
    case App.Repo.get(App.Models.Post, id) do
      nil -> {:error, "Post id #{id} not found"}
      post -> {:ok, post}
    end
  end

  def create(args, _info) do
    %App.Models.Post{}
    |> App.Models.Post.changeset(args)
    |> App.Repo.insert
  end

  def update(%{id: id, post: post_params}, _info) do
    App.Repo.get!(App.Models.Post, id)
    |> App.Models.Post.changeset(post_params)
    |> App.Repo.update
  end

  def delete(%{id: id}, _info) do
    post = App.Repo.get!(App.Models.Post, id)
    App.Repo.delete(post)
  end
end
