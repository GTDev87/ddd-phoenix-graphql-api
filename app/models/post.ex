defmodule App.Models.Post do
  use App.Web, :model

  require Logger

  schema "posts" do
    field :title, :string
    field :body, :string

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

  def ids(_, ids) do

    Logger.debug "made an ids query ids = #{inspect ids}"
    uniq_ids = Enum.uniq(ids)
    query = from p in App.Models.Post,
         where: p.id in ^uniq_ids,
         select: p

    App.Repo.all(query)
    |> Map.new(&{&1.id, &1})
  end
end
