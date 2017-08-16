defmodule App.Domains.User do
  use Absinthe.Schema.Notation
  require Logger
 
  # only expectation is id
  object :user do
    field :id, :id do
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch_dependency({&App.Models.User.ids/1, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end)
      end
    end
    field :name, :string do
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch_dependency({&App.Models.User.ids/1, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:name)}
        end)
      end
    end
  end
end