defmodule AppApi.Repo do
  use Ecto.Repo, otp_app: :app_api
  require Logger
end

defmodule AppApi.WriteRepo do
  use Ecto.Repo, otp_app: :app_api
  require Logger
end

defmodule AppApi.ReadWriteRepo do
  require Logger

  (AppApi.Repo.__info__ :functions)
  |> Enum.each(fn {func_name, arity} ->
    fn_args = AppApi.Lib.RepoUtils.create_args(AppApi.Repo, arity)
    all_fn_args = [Macro.var(:type, nil)] ++ AppApi.Lib.RepoUtils.create_args(AppApi.Repo, arity)

    def unquote(:"#{func_name}")(unquote_splicing(all_fn_args)) do
      case type do
        :mutation -> AppApi.WriteRepo
        _ -> AppApi.Repo
      end
      |> apply(unquote(func_name), unquote(fn_args))
    end
  end)
end
