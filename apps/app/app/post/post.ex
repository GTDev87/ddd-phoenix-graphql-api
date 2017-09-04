defmodule App.Post.Post do
  use App.Schema

  require Logger

  @primary_key {:uuid, :binary_id, autogenerate: false}

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
    Logger.debug "struct = #{inspect struct}"
    Logger.debug "params = #{inspect params}"
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end

  def ids(uuids, options) do
    Logger.debug "QUERY QUERY App.Post.Post.ids uuids = #{inspect uuids}"
    uniq_uuids = Enum.uniq(uuids)

    query =
      from p in App.Post.Post,
        where: p.uuid in ^uniq_uuids,
        select: p
    res = 
      options
      |> Keyword.get(:query_type, %{})
      |> App.ReadWriteRepo.all(query)

    Logger.debug "res = #{inspect res}"

    map = res
      |> Map.new(&{&1.uuid, &1})

    Logger.debug "map = #{inspect map}"
    map
  end
end
