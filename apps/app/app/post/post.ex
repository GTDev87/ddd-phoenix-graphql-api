defmodule App.Post.Post do
  use App.Schema

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
    struct
    |> cast(params, [:title, :body])
    |> validate_required([:title, :body])
  end

  def ids(uuids, options) do
    uniq_uuids = Enum.uniq(uuids)

    query =
      from p in App.Post.Post,
        where: p.uuid in ^uniq_uuids,
        select: p

    options
    |> Keyword.get(:query_type, %{})
    |> App.ReadWriteRepo.all(query)
    |> Map.new(&{&1.uuid, &1})
  end
end
