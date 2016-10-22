defmodule D20CharacterKeeper.Character do
  use D20CharacterKeeper.Web, :model

  schema "characters" do
    field :name, :string
    field :player, :string
    field :character_level, :integer
    has_many :fields, D20CharacterKeeper.Field, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :player, :character_level])
    |> cast_assoc(:fields)
    |> validate_required([:name, :player, :character_level])
    |> sort_ability_fields
  end

  defp sort_ability_fields(struct) do
    cond do
      struct |> has_fields? ->
        fields = Enum.map(struct.data.fields, &({String.to_atom(&1.name), &1}))
        sorted_fields =
          ~w(strength dexterity constitution intelligence wisdom charisma)a
          |> Enum.map(&(fields[&1]))

        data = Map.put(struct.data, :fields, sorted_fields)
        Map.put(struct, :data, data)
      true ->
        struct
    end
  end

  defp has_fields?(struct) do
    if Map.has_key?(struct, :data) do
      is_list(struct.data.fields) && length(struct.data.fields) >= 1
    else
      false
    end
  end
end
