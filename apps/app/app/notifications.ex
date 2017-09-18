defmodule App.Notifications do
  @doc """
  Wait until the given read model is updated to the given version
  """
  require Logger
  def wait_for(schema, uuid) do
    Logger.debug "schema = #{inspect schema}"
        Logger.debug "uuid = #{uuid}"

    case App.Repo.get_by(schema, uuid: uuid) do
      nil ->
        subscribe_and_wait(schema, uuid)
      projection -> {:ok, projection}
    end
  end

  # Subscribe to notifications of read model updates and wait for the expected version
  defp subscribe_and_wait(schema, uuid) do
    Registry.register(App.Post, {schema, uuid}, [])

    receive do
      {^schema, projection} -> {:ok, projection}
    after
      5_000 -> {:error, :timeout}
    end
  end
end
