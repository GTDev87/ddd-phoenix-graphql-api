defmodule App.Notifications do
  @doc """
  Wait until the given read model is updated to the given version
  """
  def wait_for(schema, uuid) do
    case App.Repo.get_by(schema, uuid: uuid) do
      nil -> subscribe_and_wait(schema, uuid)
      projection -> {:ok, projection}
    end
  end

  def publish_changes(%{post: %App.Post.Post{} = post}), do: publish(post)
  def publish_changes(%{post: {_, posts}}) when is_list(posts), do: Enum.each(posts, &publish/1)
  def publish_changes(_changes), do: :ok

  defp publish(%App.Post.Post{uuid: uuid} = post) do
    Registry.dispatch(App.Post, {App.Post.Post, uuid}, fn entries ->
      for {pid, _} <- entries, do: send(pid, {App.Post.Post, uuid})
    end)
  end

  # Subscribe to notifications of read model updates and wait for the expected version
  defp subscribe_and_wait(schema, uuid) do
    Registry.register(App.Post, {schema, uuid}, [])
    receive do
      {^schema, res_uuid} -> {:ok, res_uuid}
    after
      5_000 -> {:error, :timeout}
    end
  end
end
