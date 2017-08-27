defmodule AppApi.Models.User do
  use AppApi.Web, :model

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

  def ids(ids, options) do
    Logger.debug "QUERY QUERY AppApi.Models.User.ids ids = #{inspect ids}"

    uniq_ids = Enum.uniq(ids)
    query =
      from u in AppApi.Models.User,
        where: u.id in ^uniq_ids,
        select: u

    options
    |> Keyword.get(:query_type, %{})
    |> AppApi.ReadWriteRepo.all(query)
    |> Map.new(&{&1.id, &1})
  end
end
