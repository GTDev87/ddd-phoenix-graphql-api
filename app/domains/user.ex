defmodule App.Domains.User do
  use Absinthe.Schema.Notation
  use Absinthe.Schema
  require Logger
 
  object :user do
    field :id, :id do
      resolve fn id, _, _ ->
        Logger.debug "id id = #{id}"
        Absinthe.Resolution.Helpers.batch({App.Models.User, :ids}, id, fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:id)}
        end)
      end
    end
    field :name, :string do
      resolve fn id, _, _ ->
        Logger.debug "title id = #{id}"
        Absinthe.Resolution.Helpers.batch({App.Models.User, :ids}, id, fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:title)}
        end)
      end
    end
  end
end
