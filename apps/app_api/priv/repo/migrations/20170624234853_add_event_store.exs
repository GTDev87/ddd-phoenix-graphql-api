defmodule AppApi.Repo.Migrations.AddEventStore do
  use Ecto.Migration

  def up do
    Mix.Task.run("event_store.create")
  end

  def down do
    Mix.Task.run("event_store.drop")
  end
end
