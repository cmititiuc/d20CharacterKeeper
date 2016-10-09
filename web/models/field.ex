defmodule D20CharacterKeeper.Field do
  use D20CharacterKeeper.Web, :model

  schema "fields" do
    field :name, :string
    field :value, :integer
    belongs_to :character, D20CharacterKeeper.Character
    has_many :modifiers, D20CharacterKeeper.Modifier, on_delete: :delete_all

    timestamps()
  end

  def modified_value(field) do
    {_output, result} =
      Enum.map_reduce(field.modifiers, field.value, fn(m, acc) ->
        {m.value, m.value + acc}
      end)

    result
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :value, :character_id])
    |> cast_assoc(:modifiers)
    |> validate_required([:name, :value, :character_id])
  end
end
