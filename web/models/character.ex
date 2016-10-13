defmodule D20CharacterKeeper.Character do
  use D20CharacterKeeper.Web, :model

  import Ecto.Query
  alias D20CharacterKeeper.Repo
  alias D20CharacterKeeper.Field

  schema "characters" do
    field :name, :string
    field :player, :string
    field :character_level, :integer
    has_many :fields, Field, on_delete: :delete_all

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
  end
end
