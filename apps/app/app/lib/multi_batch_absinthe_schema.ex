defmodule App.Lib.MultiBatchAbsintheSchema do
  @behaviour Absinthe.Schema
  defmacro __using__(_params) do
    quote do
      use Absinthe.Schema

      def plugins, do: App.Lib.MultiBatchAbsintheSchema.plugins()
    end
  end

  def plugins, do: Absinthe.Plugin.defaults() ++ [App.Lib.MultiBatch]
end
