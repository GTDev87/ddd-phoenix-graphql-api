defmodule App.Models.User do
  use App.Web, :model

  require Logger

  schema "users" do
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

  def ids(ids) do
    Logger.debug "QUERY QUERY App.Models.User.ids ids = #{inspect ids}"
    uniq_ids = Enum.uniq(ids)
    query =
      from u in App.Models.User,
        where: u.id in ^uniq_ids,
        select: u

    type = :query
    App.ReadWriteRepo.all(type, query)
    |> Map.new(&{&1.id, &1})
  end
end
