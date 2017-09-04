defmodule App.Repo.Migrations.CreateProjectionVersions do
  use Ecto.Migration

  def up do
    create table(:projection_versions, primary_key: false) do
      add :projection_name, :text, primary_key: true
      add :last_seen_event_number, :bigint

      timestamps()
    end
  end

  def drop do
    drop table(:projection_versions)
  end
end
