defmodule D20CharacterKeeper.Modifier do
  use D20CharacterKeeper.Web, :model

  schema "modifiers" do
    field :value, :integer
    field :description, :string
    belongs_to :field, D20CharacterKeeper.Field

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :description])
    |> validate_required([:value, :description])
  end
end
