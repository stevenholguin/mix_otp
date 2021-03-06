defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ## Server callbacks
@doc """
Init two maps, one for bucket name -> pid and other one for refs -> name
"""
@impl true
def init(:ok) do
  names = %{}
  refs = %{}
  {:ok, {names, refs}}
end

@impl true
def handle_call({:lookup, name}, _from, state) do
  {names, _} = state
  {:reply, Map.fetch(names, name), state}
end

@impl true
def handle_cast({:create, name}, {names, refs}) do
  if Map.has_key?(names, name) do
    {:noreply, {names, refs}}
  else
    # Bad idea link the registry with each bucket, if a bucket crashes the registry crash too.
    {:ok, bucket} = KV.Bucket.start_link([])
    ref = Process.monitor(bucket)
    refs = Map.put(refs, ref, name)
    names = Map.put(names, name, bucket)
    {:noreply, {names, refs}}
  end
end

@impl true
def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
  {name, refs} = Map.pop(refs, ref)
  names = Map.delete(names, name)
  {:noreply, {names, refs}}
end

@impl true
def handle_info(msg, state) do
  require Logger
  Logger.debug("Unexpected message in KV.Registry: #{inspect(msg)}")
  {:noreply, state}
end

  # Test in console
  # {:ok, registry} = GenServer.start_link(KV.Registry, :ok)
  # GenServer.cast(registry, {:create, "shopping"})
  # {:ok, bk} = GenServer.call(registry, {:lookup, "shopping"})
end
