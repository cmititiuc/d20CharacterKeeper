defmodule D20CharacterKeeper.Router do
  use D20CharacterKeeper.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", D20CharacterKeeper do
    pipe_through :browser # Use the default browser stack

    resources "/characters", CharacterController
    resources "/fields", FieldController
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", D20CharacterKeeper do
  #   pipe_through :api
  # end
end
