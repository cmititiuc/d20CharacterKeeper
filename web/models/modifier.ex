defmodule D20CharacterKeeper.Modifier do
  use D20CharacterKeeper.Web, :model

  schema "modifiers" do
    field :value, :integer
    field :description, :string
    field :delete, :boolean, virtual: true
    belongs_to :field, D20CharacterKeeper.Field

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:value, :description], [:delete])
    |> validate_required([:value, :description])
    |> mark_for_deletion()
  end

  defp mark_for_deletion(changeset) do
    # If delete was set and it is true, let's change the action
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
