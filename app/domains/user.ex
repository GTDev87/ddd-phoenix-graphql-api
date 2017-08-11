defmodule App.Domains.User do
  use Absinthe.Schema.Notation
  require Logger
 
  # only expectation is id
  object :user do
    field :id, :id do
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch([{{App.Models.User, :ids}, id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end)
      end
    end
    field :name, :string do
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch([{{App.Models.User, :ids}, id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:title)}
        end)
      end
    end
  end
end
