defmodule D20CharacterKeeper.Repo.Migrations.CreateCharacter do
  use Ecto.Migration

  def change do
    create table(:characters) do
      add :name, :string
      add :player, :string
      add :character_level, :integer

      timestamps()
    end

  end
end
