defmodule FibonacciController do
  alias Traefik.Conn
  alias Traefik.Controller

  def compute(%Conn{} = conn, %{"n" => n} = params) do
    result = Fibonacci.sequence(n)
    response = "Result: #{result}"
    %{conn | response: response, status: 201}
  end
end
