defmodule App.Domains.Post do
  use Absinthe.Schema.Notation
  import_types App.Domains.User

  require Logger
 
  # only expectation is id
  object :post do
    field :id, :id do
      # dependency is post_id here
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end)
      end
    end
    field :title, :string do
      # dependency is post_id here
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:title)}
        end)
      end
    end
    field :body, :string do
      # dependency is post_id here
      resolve fn id, _, _ ->
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:body)}
        end)
      end
    end
    field :user, :user do
      # how do i get the user_id here if all i have access to is the id?
      # need to indicate dependencies
      # dependency is post(user_id) here

      resolve fn id, _, _ ->
        # Logger.debug "body id = #{id}"
        App.Lib.MultiBatch.batch([{{App.Models.Post, :ids}, id}, {{App.Models.User, :ids}, :user_id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end)
      end
    end
  end
end
