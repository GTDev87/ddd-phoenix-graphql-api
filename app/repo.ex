defmodule App.Repo do
  use Ecto.Repo, otp_app: :app
  require Logger
end

defmodule App.WriteRepo do
  use Ecto.Repo, otp_app: :app
  require Logger
end
