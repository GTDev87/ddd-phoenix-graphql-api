defmodule App.PostResolver do

  require Logger

  def all(_args, _info) do
    Logger.debug "all called"

    {
      :ok,
      App.Repo.all(App.Models.Post)
      |> Enum.map(fn p -> p.id end)
    }
  end

  def find(%{id: id}, _info) do
    ids = App.Repo.get(App.Models.Post, id)
    Logger.debug "find ids = #{inspect ids}"
    case ids do
      nil -> {:error, "Post id #{id} not found"}
      post -> {:ok, post.id}
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
