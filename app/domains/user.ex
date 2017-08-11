defmodule App.Domains.User do
  use Absinthe.Schema.Notation
  require Logger
 
  # only expectation is id
  object :user do
    field :id, :id do
      resolve fn id, _, _ ->
        Logger.debug "id id = #{id}"
        App.Lib.MultiBatch.batch([{{App.Models.User, :ids}, id}], fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:id)}
        end)
      end
    end
    field :name, :string do
      resolve fn id, _, _ ->
        Logger.debug "title id = #{id}"
        App.Lib.MultiBatch.batch([{{App.Models.User, :ids}, id}], fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:title)}
        end)
      end
    end
  end
end
