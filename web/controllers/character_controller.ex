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
    changeset = Character.changeset(%Character{fields: [
      %Field{name: "strength", modifiers: []},
      %Field{name: "dexterity", modifiers: []},
      %Field{name: "constitution", modifiers: []},
      %Field{name: "intelligence", modifiers: []},
      %Field{name: "wisdom", modifiers: []},
      %Field{name: "charisma", modifiers: []},
    ]})
    stats = changeset.data.fields |> Enum.map(&({String.to_atom(&1.name), &1}))
    ordered_stats =
      ~w(strength dexterity constitution intelligence wisdom charisma)a
      |> Enum.map(&({&1, stats[&1]}))
      |> Enum.with_index
    render(conn, "new.html", changeset: changeset, stats: ordered_stats)
  end

  def create(conn, %{"character" => character_params}) do
    changeset = Character.changeset(%Character{}, character_params)

    case Repo.insert(changeset) do
      {:ok, _character} ->
        conn
        |> put_flash(:info, "Character created successfully.")
        |> redirect(to: character_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, stats: []) # TODO: stats
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
    stats =
      Character.get_abilities!(id)
      |> Enum.map(&({String.to_atom(&1.name), &1}))
    ordered_stats =
      ~w(strength dexterity constitution intelligence wisdom charisma)a
      |> Enum.map(&({&1, stats[&1]}))
      |> Enum.with_index
    changeset = Character.changeset(character)
    params = %{character: character, changeset: changeset, stats: ordered_stats}

    render(conn, "edit.html", params)
  end

  def update(conn, %{"id" => id, "character" => character_params}) do
    character = Repo.get!(Character, id) |> Repo.preload([fields: :modifiers])
    stats =
      Character.get_abilities!(id)
      |> Enum.map(&({String.to_atom(&1.name), &1}))
    ordered_stats =
      ~w(strength dexterity constitution intelligence wisdom charisma)a
      |> Enum.map(&({&1, stats[&1]}))
    changeset = Character.changeset(character, character_params)
    params = %{character: character, changeset: changeset, stats: ordered_stats}

    case Repo.update(changeset) do
      {:ok, character} ->
        conn
        |> put_flash(:info, "Character updated successfully.")
        |> redirect(to: character_path(conn, :show, character))
      {:error, changeset} ->
        render(conn, "edit.html", params)
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
