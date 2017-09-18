defmodule App.User.User do
  use App.Schema

  require Logger

  # @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "users" do
    # field :id, :id
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def ids(ids, options) do
    uniq_ids = ids |> Enum.filter(fn a -> a end) |> Enum.uniq()
    query =
      from u in App.User.User,
        where: u.id in ^uniq_ids,
        select: u

    options
    |> Keyword.get(:query_type, %{})
    |> App.ReadWriteRepo.all(query)
    |> Map.new(&{&1.id, &1})
  end
end
