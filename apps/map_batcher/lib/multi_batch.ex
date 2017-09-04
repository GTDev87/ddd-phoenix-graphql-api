defmodule MapBatcher.MultiBatch do
  @moduledoc """
  Batch the resolution of multiple fields.
  ## Motivation
  Consider the following graphql query:
  ```
  {
    posts {
      author {
        name
      }
    }
  }
  ```
  `posts` returns a list of `post` objects, which has an associated `author` field.
  If the `author` field makes a call to the database we have the classic N + 1 problem.
  What we want is a way to load all authors for all posts in one database request.
  This plugin provides this, without any eager loading at the parent level. That is,
  the code for the `posts` field does not need to do anything to facilitate the
  efficient loading of its children.
  ## Example Usage
  The API for this plugin is a little on the verbose side because it is not specific
  to any particular batching mechanism. That is, this API is just as useful for an Ecto
  based DB as it is for talking to S3 or the File System. Thus we anticipate people
  (including ourselves) will be creating additional functions more tailored to each
  of those specific use cases.
  Here is an example using the `Absinthe.Resolution.Helpers.batch/3` helper.
  ```elixir
  object :post do
    field :name, :string
    field :author, :user do
      resolve fn post, _, _ ->
        batch({__MODULE__, :users_by_id}, post.author_id, fn batch_results ->
          {:ok, Map.get(batch_results, post.author_id)}
        end)
      end
    end
  end
  def users_by_id(_, user_ids) do
    users = Repo.all from u in User, where: u.id in ^user_ids
    Map.new(users, fn user -> {user.id, user} end)
  end
  ```
  Let's look at this piece by piece:
  - `{__MODULE__, :users_by_id}`: is the batching function which will be used. It must
  be a 2 arity function. For details see the `batch_fun` typedoc.
  - `post.author_id`: This is the information to be aggregated. The aggregated values
  are the second argument to the batching function.
  - `fn batch_results`: This function takes the results from the batching function.
  it should return one of the resolution function values.
  Clearly some of this could be derived for ecto functions. Check out the Absinthe.Ecto
  library for something that provides this:
  ```elixir
  field :author, :user, resolve: assoc(:author)
  ```
  Such a function could be easily built upon the API of this module.
  """

  @behaviour Absinthe.Middleware
  @behaviour Absinthe.Plugin

  require Logger

  @typedoc """
  The function to be called with the aggregate batch information.
  It comes in both a 2 tuple and 3 tuple form. The first two elements are the module
  and function name. The third element is an arbitrary parameter that is passed
  as the first argument to the batch function.
  For example, one could parameterize the `users_by_id` function from the moduledoc
  to make it more generic. Instead of doing `{__MODULE__, :users_by_id}` you could do
  `{__MODULE__, :by_id, User}`. Then the function would be:
  ```elixir
  def by_id(model, ids) do
    model
    |> where([m], m.id in ^ids)
    |> Repo.all()
    |> Map.new(&{&1.id, &1})
  end
  ```
  It could also be used to set options unique to the execution of a particular
  batching function.
  """
  @type batch_fun :: {module, atom} | {module, atom, term}

  @type post_batch_fun :: (term -> Absinthe.Type.Field.result)

  def before_resolution(acc) do
    case acc do
      %{__MODULE__ => _} ->
        put_in(acc[__MODULE__][:input], [])
      _ ->
        Map.put(acc, __MODULE__, %{input: [], output: %{}})
    end
  end

  def get_previous_batched_output(acc, batch_key, override_data_or_fn) when is_function(override_data_or_fn) do
    Logger.debug "get_previous_batched_output acc = #{inspect acc}"
    Logger.debug "get_previous_batched_output batch_key = #{inspect batch_key}"
    Logger.debug "get_previous_batched_output override_data_or_fn = #{inspect override_data_or_fn}"

    acc
    |> Map.get(__MODULE__, %{})
    |> Map.get(:output, %{})
    |> Map.get(batch_key, %{})
    |> override_data_or_fn.()
  end
  # def get_previous_batched_output(acc, batch_key, override_data_or_fn) when is_atom(override_data_or_fn) do 
  #   Logger.debug "acc = #{inspect acc}"
  #   get_previous_batched_output(acc, batch_key, &(Map.get(&1, override_data_or_fn)))
  # end
  def get_previous_batched_output(_, _, override_data_or_fn), do: override_data_or_fn

  def update_acc(acc, batch_key, batch_opts, field_data) do
    update_in(acc[__MODULE__][:input], fn
      nil -> [{{batch_key, batch_opts}, field_data}]
      data -> [{{batch_key, batch_opts}, field_data} | data]
    end)
  end

  def get_intermediate_data(acc, field) when is_function(field), do: field.(acc)
  def get_intermediate_data(acc, field) when is_atom(field), do: acc |> Map.get(field)
  def get_intermediate_data(acc, field), do: field
    

  def call(%{state: :unresolved} = res, {dependency_batch_array, post_batch_fun, batch_opts}) do
    [{batch_key, field_data} | next_dependency_batch_array] = dependency_batch_array
    resolved_field_data = get_previous_batched_output(res.acc, batch_key, field_data)
    acc = update_acc(res.acc, batch_key, batch_opts, resolved_field_data)

    %{res |
      state: :suspended,
      middleware: [{__MODULE__, {dependency_batch_array, post_batch_fun, batch_opts}} | res.middleware],
      acc: acc,
    }
  end
  def call(%{state: :suspended} = res, {dependency_batch_array, post_batch_fun, batch_opts}) do
    [{batch_key, field_data} | next_dependency_batch_array] = dependency_batch_array
    case next_dependency_batch_array do
      [] ->
        batch_data_for_fun =
          get_previous_batched_output(res.acc, batch_key, &(&1)) #passes identity through
        res
        |> Absinthe.Resolution.put_result(post_batch_fun.(batch_data_for_fun))
      _ ->
        [{next_batch_key, next_field_data} | _] = next_dependency_batch_array
        intermediate =
          get_previous_batched_output(res.acc, batch_key, &(Map.get(&1, field_data)))

        next_resolved_field_data =
          intermediate
          |> get_intermediate_data(next_field_data)

        acc = update_acc(res.acc, next_batch_key, batch_opts, next_resolved_field_data)


        Logger.debug "next acc = #{inspect acc}"
        Logger.debug "next field_data = #{inspect field_data}"
        Logger.debug "next next_batch_key = #{inspect next_batch_key}"
        Logger.debug "next batch_opts = #{inspect batch_opts}"
        Logger.debug "next intermediate = #{inspect intermediate}"
        Logger.debug "next next_resolved_field_data = #{inspect next_resolved_field_data}"
        Logger.debug "next next_field_data = #{inspect next_field_data}"

        %{res |
          state: :suspended,
          middleware: [{__MODULE__, {next_dependency_batch_array, post_batch_fun, batch_opts}} | res.middleware],
          acc: acc,
        }
    end
  end

  def after_resolution(acc) do
    output = do_batching(acc)
    merged_output = Map.merge(acc[__MODULE__][:output], output)
    put_in(acc[__MODULE__][:output], merged_output)
  end

  defp do_batching(acc) do
    acc
    |> Map.get(__MODULE__, %{})
    |> Map.get(:input, %{})
    |> Enum.reject(fn({{fun_tuple, _}, batch_data}) ->
        acc
        |> Map.get(__MODULE__, %{})
        |> Map.get(:output, %{})
        |> Map.get(fun_tuple, %{})
        |> Map.has_key?(batch_data)
      end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {{batch_fun, batch_opts}, batch_data}->
      {batch_opts, Task.async(fn ->
        {batch_fun, batch_fun.(batch_data, batch_opts)}
      end)}
    end)
    |> Map.new(fn {batch_opts, task} ->
      timeout = Keyword.get(batch_opts, :timeout, 5_000)
      Task.await(task, timeout)
    end)
  end

  defp call_batch_fun({module, fun}, batch_data) do
    call_batch_fun({module, fun, []}, batch_data)
  end
  defp call_batch_fun({module, fun, config}, batch_data) do
    apply(module, fun, [config, batch_data])
  end

  # If the flag is set we need to do another resolution phase.
  # otherwise, we do not
  def pipeline(pipeline, acc) do
    case acc[__MODULE__][:input] do
      [_|_] ->
        [Absinthe.Phase.Document.Execution.Resolution | pipeline]
      _ ->
        pipeline
    end
  end

  @spec batch_serial_dependencies([{MapBatcher.MultiBatch.batch_fun, term}], MapBatcher.MultiBatch.post_batch_fun) :: {:plugin, MapBatcher.MultiBatch, term}
  @spec batch_serial_dependencies([{MapBatcher.MultiBatch.batch_fun, term}], MapBatcher.MultiBatch.post_batch_fun, opts :: Keyword.t):: {:plugin, MapBatcher.MultiBatch, term}
  def batch_serial_dependencies(dependency_batch_array, post_batch_fun, opts \\ []) do
    batch_config = {dependency_batch_array, post_batch_fun, opts}
    {:middleware, MapBatcher.MultiBatch, batch_config}
  end

  @spec batch_dependency({MapBatcher.MultiBatch.batch_fun, term}, MapBatcher.MultiBatch.post_batch_fun) :: {:plugin, MapBatcher.MultiBatch, term}
  @spec batch_dependency({MapBatcher.MultiBatch.batch_fun, term}, MapBatcher.MultiBatch.post_batch_fun, opts :: Keyword.t):: {:plugin, MapBatcher.MultiBatch, term}
  def batch_dependency(dependency_batch, post_batch_fun, opts \\ []) do
    batch_config = {[dependency_batch], post_batch_fun, opts}
    {:middleware, MapBatcher.MultiBatch, batch_config}
  end

  # @spec batch_parallel_dependencies([{MapBatcher.MultiBatch.batch_fun, term}], MapBatcher.MultiBatch.post_batch_fun) :: {:plugin, MapBatcher.MultiBatch, term}
  # @spec batch_parallel_dependencies([{MapBatcher.MultiBatch.batch_fun, term}], MapBatcher.MultiBatch.post_batch_fun, opts :: Keyword.t):: {:plugin, MapBatcher.MultiBatch, term}
  # def batch_parallel_dependencies(dependency_batch_array, post_batch_fun, opts \\ []) do
  #   batch_config = {dependency_batch_array, post_batch_fun, opts}
  #   {:middleware, MapBatcher.MultiBatch, batch_config}
  # end
end