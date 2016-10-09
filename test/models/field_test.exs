defmodule D20CharacterKeeper.FieldTest do
  use D20CharacterKeeper.ModelCase

  alias D20CharacterKeeper.Field
  alias D20CharacterKeeper.Character

  @valid_attrs %{name: "some content", value: 42, character_id: 123}
  @invalid_attrs %{}

  test "changeset with valid attributes and valid struct" do
    changeset = Field.changeset(%Field{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes and valid struct" do
    changeset = Field.changeset(%Field{}, @invalid_attrs)
    refute changeset.valid?
  end
end
