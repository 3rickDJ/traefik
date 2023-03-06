defmodule Traefik.GenericServer do
  def start(module, parent \\ self(), init \\ []) do
    spawn(__MODULE__, :loop, [module, parent, init])
  end

  @doc """
  ASYNC calls for the server
  """
  def cast(pid_server, message) do
    send(pid_server, message)
  end

  @doc """
  SYNC calls for the server
  """
  def call(_pid_server, _message) do
  end

  def loop(module, parent, state) do
    receive do
      :kill ->
        :killed

      {:cast, message} ->
        {:ok, result, new_state} = module.handle_cast(message, parent, state)
        send(parent, {:ok, {module, message, result, new_state}})
        loop(module, parent, new_state)
    end
  end
end
