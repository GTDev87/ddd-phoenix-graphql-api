defmodule Conduit.Repo.Migrations.PostUuids do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\" WITH SCHEMA public;"

    alter table(:posts) do
      remove :id # remove the existing id column
      add :uuid, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
    end

    create unique_index(:posts, [:uuid])
  end
end
