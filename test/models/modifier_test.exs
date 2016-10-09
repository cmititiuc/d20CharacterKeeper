defmodule D20CharacterKeeper.ModifierTest do
  use D20CharacterKeeper.ModelCase

  alias D20CharacterKeeper.Modifier

  @valid_attrs %{description: "some content", value: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Modifier.changeset(%Modifier{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Modifier.changeset(%Modifier{}, @invalid_attrs)
    refute changeset.valid?
  end
end
