defmodule Flusomail.Repo do
  use Ecto.Repo,
    otp_app: :flusomail,
    adapter: Ecto.Adapters.Postgres
end
