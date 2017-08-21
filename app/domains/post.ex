defmodule App.Domains.Post do
  use Absinthe.Schema.Notation
  import_types App.Domains.User

  require Logger
 
  # only expectation is id
  object :post do
    field :id, :id do
      # dependency is post_id here
      resolve fn id, _, info ->
        type = App.Lib.Resolver.query_type(info)
        # Logger.debug "post id type = #{type}"

        App.Lib.MultiBatch.batch_dependency({&App.Models.Post.ids/1, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:id)}
        end)
      end
    end
    field :title, :string do
      # dependency is post_id here
      resolve fn id, _, info ->
        type = App.Lib.Resolver.query_type(info)
        # Logger.debug "post title type = #{type}"

        App.Lib.MultiBatch.batch_dependency({&App.Models.Post.ids/1, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:title)}
        end)
      end
    end
    field :body, :string do
      # dependency is post_id here
      resolve fn id, _, info ->
        type = App.Lib.Resolver.query_type(info)
        # Logger.debug "post body type = #{type}"

        App.Lib.MultiBatch.batch_dependency({&App.Models.Post.ids/1, id}, fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:body)}
        end)
      end
    end
    field :user, :user do
      # how do i get the user_id here if all i have access to is the id?
      # need to indicate dependencies
      # dependency is post(user_id) here

      resolve fn id, _, info ->
        type = App.Lib.Resolver.query_type(info)
        # Logger.debug "post user type = #{type}"
        App.Lib.MultiBatch.batch_serial_dependencies([{&App.Models.Post.ids/1, id}, {&App.Models.User.ids/1, :user_id}], fn (batch_results) ->

          {:ok, batch_results |> Map.get(id, %{}) |> Map.get(:id)}
        end)
      end
    end
    field :user_name, :string do
      # how do i get the user_id here if all i have access to is the id?
      # need to indicate dependencies
      # dependency is post(user_id) here



      resolve fn id, _, info ->
        type = App.Lib.Resolver.query_type(info)
        # Logger.debug "post user_name type = #{type}"
        App.Lib.MultiBatch.batch_serial_dependencies([{&App.Models.Post.ids/1, id}, {&App.Models.User.ids/1, :user_id}], fn (batch_results) ->
          {:ok, batch_results |> Map.get(id) |> Map.get(:name)}
        end)
      end
    end
  end
end
