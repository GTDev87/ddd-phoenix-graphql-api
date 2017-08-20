defmodule App.Repo do
  use Ecto.Repo, otp_app: :app
  require Logger
end

defmodule App.WriteRepo do
  use Ecto.Repo, otp_app: :app
  require Logger
end

defmodule App.RepoUtil do
  def create_args(_, 0),
    do: []
  def create_args(fn_mdl, arg_cnt),
    do: Enum.map(1..arg_cnt, &(Macro.var (:"arg#{&1}"), fn_mdl))
end

defmodule App.ReadWriteRepo do
  require Logger

  (App.Repo.__info__ :functions)
  |> Enum.each(fn {func_name, arity} ->
    fn_args = App.RepoUtil.create_args(App.Repo, arity)
    all_fn_args = [Macro.var(:type, nil)] ++ App.RepoUtil.create_args(App.Repo, arity)

    def unquote(:"#{func_name}")(unquote_splicing(all_fn_args)) do
      case type do
        :mutation -> App.WriteRepo
        _ -> App.Repo
      end
      |> apply(unquote(func_name), unquote(fn_args))
    end
  end)
end
