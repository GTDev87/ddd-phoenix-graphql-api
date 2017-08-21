defmodule App.PostResolver do

  require Logger

  def all(_args, _info) do
    {
      :ok,
      App.ReadWriteRepo.all(:query, App.Models.Post)
      |> Enum.map(fn p -> p.id end)
    }
  end

  def find(%{id: id}, _info) do
    App.ReadWriteRepo.get(:query, App.Models.Post, id)
    |> case do
      nil -> {:error, "Post id #{id} not found"}
      post -> {:ok, post.id}
    end
  end

  def create(args, _info) do
    changeset =
      %App.Models.Post{}
      |> App.Models.Post.changeset(args)
    {:ok, returned_post} = App.ReadWriteRepo.insert(:mutation, changeset)
    {:ok, returned_post.id}
  end

  def update(%{id: id, post: post_params}, _info) do
    changeset =
      App.Repo.get!(App.Models.Post, id)
      |> App.Models.Post.changeset(post_params)
    {:ok, returned_post} = App.Repo.update(:mutation, changeset)
    {:ok, returned_post.id}
  end

  def delete(%{id: id}, _info) do
    post = App.Repo.get!(App.Models.Post, id)
    {:ok, returned_post} = App.Repo.delete(:mutation, post)
    {:ok, returned_post.id}
  end
end
