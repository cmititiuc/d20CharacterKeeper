defmodule D20CharacterKeeper.Repo.Migrations.CreateModifier do
  use Ecto.Migration

  def change do
    create table(:modifiers) do
      add :value, :integer
      add :description, :string
      add :field_id, references(:fields, on_delete: :nothing)

      timestamps()
    end
    create index(:modifiers, [:field_id])

  end
end
