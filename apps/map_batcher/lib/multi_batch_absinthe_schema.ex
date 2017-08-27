defmodule MapBatcher.MultiBatchAbsintheSchema do
  @behaviour Absinthe.Schema
  defmacro __using__(_params) do
    quote do
      use Absinthe.Schema

      def plugins, do: MapBatcher.MultiBatchAbsintheSchema.plugins()
    end
  end

  def plugins, do: Absinthe.Plugin.defaults() ++ [MapBatcher.MultiBatch]
end
