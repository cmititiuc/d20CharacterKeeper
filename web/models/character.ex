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
    |> sort_fields
  end

  defp sort_fields(struct) do
    case Map.has_key?(struct, :data) && is_list(struct.data.fields) do
      false ->
        struct
      true ->
        fields = struct.data.fields |> Enum.map(&({String.to_atom(&1.name), &1}))
        sorted_fields =
          ~w(strength dexterity constitution intelligence wisdom charisma)a
          |> Enum.map(&(fields[&1]))

        data = Map.put(struct.data, :fields, sorted_fields)
        Map.put(struct, :data, data)
    end
  end
end
