defmodule D20CharacterKeeper.CharacterController do
  use D20CharacterKeeper.Web, :controller

  alias D20CharacterKeeper.Character
  alias D20CharacterKeeper.Field

  @abilities [
    strength: "STR",
    dexterity: "DEX",
    constitution: "CON",
    intelligence: "INT",
    wisdom: "WIS",
    charisma: "CHA"
  ]

  def index(conn, _params) do
    characters = Repo.all(Character)
    render(conn, "index.html", characters: characters)
  end

  def new(conn, _params) do
    changeset = Character.changeset(%Character{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"character" => character_params}) do
    changeset = Character.changeset(%Character{}, character_params)

    case Repo.insert(changeset) do
      {:ok, _character} ->
        conn
        |> put_flash(:info, "Character created successfully.")
        |> redirect(to: character_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    character = Repo.get!(Character, id) |> Repo.preload([fields: :modifiers])
    {_output, fields} =
      Enum.map_reduce(character.fields, %{}, fn(field, acc) ->
        field_values = %{field.name => %{
          modified_value: Field.modified_value(field),
          value: field.value,
          modifiers: Enum.map(field.modifiers, fn(m) ->
            "#{m.value} #{if m.description, do: "(#{m.description})"}"
          end)
        }}

        {field, Map.merge(acc, field_values)}
      end)
    params = %{character: character, fields: fields, abilities: @abilities}

    render(conn, "show.html", params)
  end

  def edit(conn, %{"id" => id}) do
    character = Repo.get!(Character, id) |> Repo.preload([fields: :modifiers])
    changeset = Character.changeset(character)
    render(conn, "edit.html", character: character, changeset: changeset)
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Repo.get!(Character, id) |> Repo.preload([fields: :modifiers])
    changeset = Character.changeset(character, character_params)

    case Repo.update(changeset) do
      {:ok, character} ->
        conn
        |> put_flash(:info, "Character updated successfully.")
        |> redirect(to: character_path(conn, :show, character))
      {:error, changeset} ->
        render(conn, "edit.html", character: character, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    character = Repo.get!(Character, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(character)

    conn
    |> put_flash(:info, "Character deleted successfully.")
    |> redirect(to: character_path(conn, :index))
  end
end
