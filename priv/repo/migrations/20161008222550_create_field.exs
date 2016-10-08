defmodule D20CharacterKeeper.Repo.Migrations.CreateField do
  use Ecto.Migration

  def change do
    create table(:fields) do
      add :name, :string
      add :value, :integer
      add :character_id, references(:characters, on_delete: :nothing)

      timestamps()
    end
    create index(:fields, [:character_id])

  end
end
