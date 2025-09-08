defmodule Flusomail.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FlusomailWeb.Telemetry,
      Flusomail.Repo,
      {DNSCluster, query: Application.get_env(:flusomail, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Flusomail.PubSub},
      # Start a worker by calling: Flusomail.Worker.start_link(arg)
      # {Flusomail.Worker, arg},
      # Start to serve requests, typically the last entry
      FlusomailWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Flusomail.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FlusomailWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
