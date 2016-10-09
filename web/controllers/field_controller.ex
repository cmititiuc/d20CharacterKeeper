defmodule D20CharacterKeeper.FieldController do
  use D20CharacterKeeper.Web, :controller

  alias D20CharacterKeeper.Field
  alias D20CharacterKeeper.Character

  def index(conn, _params) do
    fields = Repo.all(Field) |> Repo.preload(:character)
    render(conn, "index.html", fields: fields)
  end

  def new(conn, _params) do
    changeset = Field.changeset(%Field{})
    characters =
      Repo.all(Character) |> Enum.map(&({&1.name, &1.id})) |> Enum.into(%{})
    render(conn, "new.html", changeset: changeset, characters: characters)
  end

  def create(conn, %{"field" => field_params}) do
    changeset = Field.changeset(%Field{}, field_params)
    characters =
      Repo.all(Character) |> Enum.map(&({&1.name, &1.id})) |> Enum.into(%{})

    case Repo.insert(changeset) do
      {:ok, _field} ->
        conn
        |> put_flash(:info, "Field created successfully.")
        |> redirect(to: field_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, characters: characters)
    end
  end

  def show(conn, %{"id" => id}) do
    field = Repo.get!(Field, id) |> Repo.preload([:character, :modifiers])
    render(conn, "show.html", field: field)
  end

  def edit(conn, %{"id" => id}) do
    field = Repo.get!(Field, id) |> Repo.preload([:character, :modifiers])
    characters =
      Repo.all(Character) |> Enum.map(&({&1.name, &1.id})) |> Enum.into(%{})
    changeset = Field.changeset(field)
    locals = %{field: field, changeset: changeset, characters: characters}

    render(conn, "edit.html", locals)
  end

  def update(conn, %{"id" => id, "field" => field_params}) do
    field = Repo.get!(Field, id) |> Repo.preload([:character, :modifiers])
    characters =
      Repo.all(Character) |> Enum.map(&({&1.name, &1.id})) |> Enum.into(%{})
    changeset = Field.changeset(field, field_params)

    case Repo.update(changeset) do
      {:ok, field} ->
        conn
        |> put_flash(:info, "Field updated successfully.")
        |> redirect(to: field_path(conn, :show, field))
      {:error, changeset} ->
        locals = %{field: field, changeset: changeset, characters: characters}
        render(conn, "edit.html", locals)
    end
  end

  def delete(conn, %{"id" => id}) do
    field = Repo.get!(Field, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(field)

    conn
    |> put_flash(:info, "Field deleted successfully.")
    |> redirect(to: field_path(conn, :index))
  end
end
