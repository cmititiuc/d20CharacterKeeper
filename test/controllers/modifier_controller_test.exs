defmodule D20CharacterKeeper.ModifierControllerTest do
  use D20CharacterKeeper.ConnCase

  alias D20CharacterKeeper.Modifier
  @valid_attrs %{description: "some content", value: 42}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, modifier_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing modifiers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, modifier_path(conn, :new)
    assert html_response(conn, 200) =~ "New modifier"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, modifier_path(conn, :create), modifier: @valid_attrs
    assert redirected_to(conn) == modifier_path(conn, :index)
    assert Repo.get_by(Modifier, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, modifier_path(conn, :create), modifier: @invalid_attrs
    assert html_response(conn, 200) =~ "New modifier"
  end

  test "shows chosen resource", %{conn: conn} do
    modifier = Repo.insert! %Modifier{}
    conn = get conn, modifier_path(conn, :show, modifier)
    assert html_response(conn, 200) =~ "Show modifier"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, modifier_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    modifier = Repo.insert! %Modifier{}
    conn = get conn, modifier_path(conn, :edit, modifier)
    assert html_response(conn, 200) =~ "Edit modifier"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    modifier = Repo.insert! %Modifier{}
    conn = put conn, modifier_path(conn, :update, modifier), modifier: @valid_attrs
    assert redirected_to(conn) == modifier_path(conn, :show, modifier)
    assert Repo.get_by(Modifier, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    modifier = Repo.insert! %Modifier{}
    conn = put conn, modifier_path(conn, :update, modifier), modifier: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit modifier"
  end

  test "deletes chosen resource", %{conn: conn} do
    modifier = Repo.insert! %Modifier{}
    conn = delete conn, modifier_path(conn, :delete, modifier)
    assert redirected_to(conn) == modifier_path(conn, :index)
    refute Repo.get(Modifier, modifier.id)
  end
end
