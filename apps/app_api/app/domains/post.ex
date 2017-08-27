defmodule AppApi.Domains.Post do
  use Absinthe.Schema.Notation
  import_types AppApi.Domains.User

  require Logger
 
  # only expectation is id
  object :post do
    field :id, :id do
      resolve fn id, _, info ->
        AppApi.Lib.MultiBatch.batch_dependency({&AppApi.Models.Post.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end, query_type: AppApi.Lib.Resolver.query_type(info))
      end
    end
    field :title, :string do
      resolve fn id, _, info ->
        AppApi.Lib.MultiBatch.batch_dependency({&AppApi.Models.Post.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:title)}
        end, query_type: AppApi.Lib.Resolver.query_type(info))
      end
    end
    field :body, :string do
      resolve fn id, _, info ->
        AppApi.Lib.MultiBatch.batch_dependency({&AppApi.Models.Post.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:body)}
        end, query_type: AppApi.Lib.Resolver.query_type(info))
      end
    end
    field :user, :user do
      resolve fn id, _, info ->
        AppApi.Lib.MultiBatch.batch_serial_dependencies([{&AppApi.Models.Post.ids/2, id}, {&AppApi.Models.User.ids/2, :user_id}], fn (batch_results) ->

          {:ok, batch_results |> Map.get(id, %{}) |> Map.get(:id)}
        end, query_type: AppApi.Lib.Resolver.query_type(info))
      end
    end
    field :user_name, :string do
      resolve fn id, _, info ->
        AppApi.Lib.MultiBatch.batch_serial_dependencies([{&AppApi.Models.Post.ids/2, id}, {&AppApi.Models.User.ids/2, :user_id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:name)}
        end, query_type: AppApi.Lib.Resolver.query_type(info))
      end
    end
  end
end
