defmodule CurrencyExchangeWeb.Router do
  use CurrencyExchangeWeb, :router

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

  scope "/", CurrencyExchangeWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", CurrencyExchangeWeb do
    pipe_through :api

    post "/exchange", PageController, :exchange
  end
end
