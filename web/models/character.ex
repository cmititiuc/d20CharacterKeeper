defmodule D20CharacterKeeper.Character do
  use D20CharacterKeeper.Web, :model

  schema "characters" do
    field :name, :string
    field :player, :string
    field :character_level, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :player, :character_level])
    |> validate_required([:name, :player, :character_level])
  end
end
