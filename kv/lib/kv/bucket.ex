defmodule KV.Bucket do
use Agent

@doc """
  Starts a new bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

  # """
  #   naming proocess
  #   Agent.start_link(fn -> %{} end, name: :shopping)
  #   KV.Bucket.put(:shopping, "milk", 1)
  #   KV.Bucket.get(:shopping, "milk")
  # """

  # Console example
  # Monitorin process
  # {:ok, pid} = KV.Bucket.start_link([])
  # Process.monitor(pid)
  # Agent.stop(pid)


end
