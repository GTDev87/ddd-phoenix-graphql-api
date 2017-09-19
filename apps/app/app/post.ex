defmodule App.Post do
  use Absinthe.Schema.Notation
  
  import_types App.User

  alias App.Post.Commands.CreatePost
  alias App.Post.Events.PostCreated

  # only expectation is id
  object :post do
    field :uuid, :id do
      resolve fn uuid, _, info ->
        MapBatcher.MultiBatch.batch_dependency({&App.Post.Post.ids/2, uuid}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(uuid) |> Map.get(:uuid)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :title, :string do
      resolve fn uuid, _, info ->
        MapBatcher.MultiBatch.batch_dependency({&App.Post.Post.ids/2, uuid}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(uuid) |> Map.get(:title)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :body, :string do
      resolve fn uuid, _, info ->
        MapBatcher.MultiBatch.batch_dependency({&App.Post.Post.ids/2, uuid}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(uuid) |> Map.get(:body)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :user, :user do
      resolve fn uuid, _, info ->
        MapBatcher.MultiBatch.batch_serial_dependencies([{&App.Post.Post.ids/2, uuid}, {&App.User.User.ids/2, :user_id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(uuid, %{}) |> Map.get(:id)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :user_name, :string do
      resolve fn uuid, _, info ->
        MapBatcher.MultiBatch.batch_serial_dependencies([{&App.Post.Post.ids/2, uuid}, {&App.User.User.ids/2, :user_id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(uuid, %{}) |> Map.get(:name)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
  end

  # Operations
  def all(_args, info) do
    {
      :ok,
      App.ReadWriteRepo.all(:query, App.Post.Post)
      |> Enum.map(fn p -> p.uuid end)
    }
  end

  def find(%{id: id}, info) do
    App.ReadWriteRepo.get(:query, App.Post.Post, id)
    |> case do
      nil -> {:error, "Post id #{id} not found"}
      post -> {:ok, post.uuid}
    end
  end


  # Command routing to Event

  # mutations

  def create(args, info) do
    uuid = UUID.uuid4()
    args
    |> CreatePost.new()
    |> CreatePost.assign_uuid(uuid)
    |> App.Router.dispatch(include_aggregate_version: true)
    |> case do
      {:ok, version} -> App.Notifications.wait_for(App.Post.Post, uuid)
      reply -> reply
    end
  end

  def update(%{id: id, post: post_params}, info) do
    changeset =
      App.Repo.get!(App.Post.Post, id)
      |> App.Post.Post.changeset(post_params)
    {:ok, returned_post} = App.Repo.update(:mutation, changeset)
    {:ok, returned_post.uuid}
  end

  def delete(%{id: id}, info) do
    post = App.Repo.get!(App.Post.Post, id)
    {:ok, returned_post} = App.Repo.delete(:mutation, post)
    {:ok, returned_post.uuid}
  end
end
