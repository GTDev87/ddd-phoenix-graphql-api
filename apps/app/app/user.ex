defmodule App.User do
  use Absinthe.Schema.Notation
  require Logger
 
  # only expectation is id
  object :user do
    field :id, :id do
      resolve fn id, _, info ->
        MapBatcher.MultiBatch.batch_dependency({&App.User.User.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
    field :name, :string do
      resolve fn id, _, info ->
        MapBatcher.MultiBatch.batch_dependency({&App.User.User.ids/2, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:name)}
        end, query_type: App.Lib.Resolver.query_type(info))
      end
    end
  end
end
