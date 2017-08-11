defmodule App.Models.Post do
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

  def ids(ids) do
    Logger.debug "QUERY QUERY App.Models.Post.ids ids = #{inspect ids}"
    uniq_ids = Enum.uniq(ids)
    query =
      from p in App.Models.Post,
        where: p.id in ^uniq_ids,
        select: p

    query
    |> App.Repo.all()
    |> Map.new(&{&1.id, &1})
  end
end
