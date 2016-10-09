defmodule D20CharacterKeeper.ModifierController do
  use D20CharacterKeeper.Web, :controller

  alias D20CharacterKeeper.Modifier

  def index(conn, _params) do
    modifiers = Repo.all(Modifier)
    render(conn, "index.html", modifiers: modifiers)
  end

  def new(conn, _params) do
    changeset = Modifier.changeset(%Modifier{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"modifier" => modifier_params}) do
    changeset = Modifier.changeset(%Modifier{}, modifier_params)

    case Repo.insert(changeset) do
      {:ok, _modifier} ->
        conn
        |> put_flash(:info, "Modifier created successfully.")
        |> redirect(to: modifier_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    modifier = Repo.get!(Modifier, id)
    render(conn, "show.html", modifier: modifier)
  end

  def edit(conn, %{"id" => id}) do
    modifier = Repo.get!(Modifier, id)
    changeset = Modifier.changeset(modifier)
    render(conn, "edit.html", modifier: modifier, changeset: changeset)
  end

  def update(conn, %{"id" => id, "modifier" => modifier_params}) do
    modifier = Repo.get!(Modifier, id)
    changeset = Modifier.changeset(modifier, modifier_params)

    case Repo.update(changeset) do
      {:ok, modifier} ->
        conn
        |> put_flash(:info, "Modifier updated successfully.")
        |> redirect(to: modifier_path(conn, :show, modifier))
      {:error, changeset} ->
        render(conn, "edit.html", modifier: modifier, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    modifier = Repo.get!(Modifier, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(modifier)

    conn
    |> put_flash(:info, "Modifier deleted successfully.")
    |> redirect(to: modifier_path(conn, :index))
  end
end
