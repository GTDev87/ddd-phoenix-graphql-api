defmodule App.Post do
  use Absinthe.Schema.Notation
  import_types App.User

  require Logger
 
  # only expectation is id
  object :post do
    field :id, :id do
      resolve fn id, _, info ->
        App.Lib.MultiBatch.batch_dependency({&App.Post.Post.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :title, :string do
      resolve fn id, _, info ->
        App.Lib.MultiBatch.batch_dependency({&App.Post.Post.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:title)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :body, :string do
      resolve fn id, _, info ->
        App.Lib.MultiBatch.batch_dependency({&App.Post.Post.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:body)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :user, :user do
      resolve fn id, _, info ->
        App.Lib.MultiBatch.batch_serial_dependencies([{&App.Post.Post.ids/2, id}, {&App.User.User.ids/2, :user_id}], fn (batch_results) ->

          {:ok, batch_results |> Map.get(id, %{}) |> Map.get(:id)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :user_name, :string do
      resolve fn id, _, info ->
        App.Lib.MultiBatch.batch_serial_dependencies([{&App.Post.Post.ids/2, id}, {&App.User.User.ids/2, :user_id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:name)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
  end

  # Operations
  def all(_args, info) do
    {
      :ok,
      App.ReadWriteRepo.all(:query, App.Post.Post)
      |> Enum.map(fn p -> p.id end)
    }
  end

  def find(%{id: id}, info) do
    App.ReadWriteRepo.get(:query, App.Post.Post, id)
    |> case do
      nil -> {:error, "Post id #{id} not found"}
      post -> {:ok, post.id}
    end
  end

  def create(args, info) do
    changeset =
      %App.Post.Post{}
      |> App.Post.Post.changeset(args)
    {:ok, returned_post} = App.ReadWriteRepo.insert(:mutation, changeset)
    {:ok, returned_post.id}
  end

  def update(%{id: id, post: post_params}, info) do
    changeset =
      App.Repo.get!(App.Post.Post, id)
      |> App.Post.Post.changeset(post_params)
    {:ok, returned_post} = App.Repo.update(:mutation, changeset)
    {:ok, returned_post.id}
  end

  def delete(%{id: id}, info) do
    post = App.Repo.get!(App.Post.Post, id)
    {:ok, returned_post} = App.Repo.delete(:mutation, post)
    {:ok, returned_post.id}
  end
end
