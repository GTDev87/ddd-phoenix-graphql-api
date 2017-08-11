defmodule App.Domains.Post do
  use Absinthe.Schema.Notation
  import_types App.Domains.User
 
  # only expectation is id
  object :post do
    field :id, :id do
      # dependency is post_id here
      resolve fn id, _, _ ->
        # Logger.debug "id id = #{id}"
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}], fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:id)}
        end)
      end
    end
    field :title, :string do
      # dependency is post_id here
      resolve fn id, _, _ ->
        # Logger.debug "title id = #{id}"
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}], fn (batch_results) ->
          # Logger.debug "batch_results = #{inspect batch_results}"
          {:ok, Map.get(batch_results, id) |> Map.get(:title)}
        end)
      end
    end
    field :body, :string do
      # dependency is post_id here
      resolve fn id, _, _ ->
        # Logger.debug "body id = #{id}"
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}], fn (batch_results) ->
          {:ok, Map.get(batch_results, id) |> Map.get(:body)}
        end)
      end
    end
    field :user, :user do
      # how do i get the user_id here if all i have access to is the id?
      # need to indicate dependencies
      # dependency is post(user_id) here

      resolve fn _, _, _ ->
        # Logger.debug "user user_id = #{user_id}"
        # Absinthe.Resolution.Helpers.batch({App.Models.User, :ids}, user_id, fn (batch_results) ->
        #   {:ok, Map.get(batch_results, id) |> Map.get(:body)}
        # end)
        {:ok, nil}
      end
    end
  end
end
