defmodule App.Domains.Post do
  use Absinthe.Schema.Notation
  use Absinthe.Schema
  require Logger
 
  object :post do
    field :id, :id do
      resolve fn id, _, _ ->
        Logger.debug "id id = #{id}"
        Absinthe.Resolution.Helpers.batch({App.Models.Post, :ids}, id, fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:id)}
        end)
      end
    end
    field :title, :string do
      resolve fn id, _, _ ->
        Logger.debug "title id = #{id}"
        Absinthe.Resolution.Helpers.batch({App.Models.Post, :ids}, id, fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:title)}
        end)
      end
    end
    field :body, :string do
      resolve fn id, _, _ ->
        Logger.debug "body id = #{id}"
        Absinthe.Resolution.Helpers.batch({App.Models.Post, :ids}, id, fn (batch_results) ->
          {:ok, Map.get(batch_results, id) |> Map.get(:body)}
        end)
      end
    end

  end
end
