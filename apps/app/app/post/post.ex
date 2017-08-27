defmodule App.Post.Post do
  use App.Web, :model

  require Logger

  schema "posts" do
    field :title, :string
    field :body, :string
    field :user_id, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end

  def ids(ids, options) do
    Logger.debug "QUERY QUERY App.Post.Post.ids ids = #{inspect ids}"
    uniq_ids = Enum.uniq(ids)

    query =
      from p in App.Post.Post,
        where: p.id in ^uniq_ids,
        select: p
    options
    |> Keyword.get(:query_type, %{})
    |> App.ReadWriteRepo.all(query)
    |> Map.new(&{&1.id, &1})
  end
end
