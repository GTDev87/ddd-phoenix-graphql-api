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

  def ids(_, ids) do

    Logger.debug "made a user ids query ids = #{inspect ids}"
    uniq_ids = Enum.uniq(ids)
    query =
      from u in App.Models.User,
        where: u.id in ^uniq_ids,
        select: u

    query
    |> App.Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
