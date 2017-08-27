defmodule AppApi.PostResolver do

  require Logger

  def all(_args, info) do
    type = AppApi.Lib.Resolver.query_type(info)
    # Logger.debug "all type = #{type}"
    {
      :ok,
      AppApi.ReadWriteRepo.all(:query, AppApi.Models.Post)
      |> Enum.map(fn p -> p.id end)
    }
  end

  def find(%{id: id}, info) do
    type = AppApi.Lib.Resolver.query_type(info)
    Logger.debug "find type = #{type}"
    # Logger.debug "_info.parent_type.name = #{inspect _info.parent_type.name}"
    AppApi.ReadWriteRepo.get(:query, AppApi.Models.Post, id)
    |> case do
      nil -> {:error, "Post id #{id} not found"}
      post -> {:ok, post.id}
    end
  end

  def create(args, info) do
    type = AppApi.Lib.Resolver.query_type(info)
    Logger.debug "create type = #{type}"
    
    changeset =
      %AppApi.Models.Post{}
      |> AppApi.Models.Post.changeset(args)
    {:ok, returned_post} = AppApi.ReadWriteRepo.insert(:mutation, changeset)
    {:ok, returned_post.id}
  end

  def update(%{id: id, post: post_params}, info) do
    type = AppApi.Lib.Resolver.query_type(info)
    Logger.debug "update type = #{type}"

    changeset =
      AppApi.Repo.get!(AppApi.Models.Post, id)
      |> AppApi.Models.Post.changeset(post_params)
    {:ok, returned_post} = AppApi.Repo.update(:mutation, changeset)
    {:ok, returned_post.id}
  end

  def delete(%{id: id}, info) do
    type = AppApi.Lib.Resolver.query_type(info)
    Logger.debug "delete type = #{type}"

    post = AppApi.Repo.get!(AppApi.Models.Post, id)
    {:ok, returned_post} = AppApi.Repo.delete(:mutation, post)
    {:ok, returned_post.id}
  end
end
