defmodule AppApi.Schema do
  use MapBatcher.MultiBatchAbsintheSchema
  import_types App.Post

  query do
    field :posts, list_of(:post), resolve: &App.Post.all/2

    field :post, :post do
      arg :id, non_null(:id)
      resolve &App.Post.find/2
    end
  end

  input_object :update_post_params do
    field :title, non_null(:string)
    field :body, non_null(:string)
  end

  mutation do
    field :create_post, type: :post do
      arg :title, non_null(:string)
      arg :body, non_null(:string)

      resolve &App.Post.create/2
    end

    field :update_post, type: :post do
      arg :id, non_null(:integer)
      arg :post, :update_post_params

      resolve &App.Post.update/2
    end

    field :delete_post, type: :post do
      arg :id, non_null(:integer)

      resolve &App.Post.delete/2
    end
  end
end
