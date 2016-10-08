defmodule D20CharacterKeeper.Field do
  use D20CharacterKeeper.Web, :model

  schema "fields" do
    field :name, :string
    field :value, :integer
    belongs_to :character, D20CharacterKeeper.Character

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :value, :character_id])
    |> validate_required([:name, :value, :character_id])
  end
end
