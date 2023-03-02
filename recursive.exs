defmodule Recursive do
  def factorial(0, acc), do: acc

  def factorial(n, acc) do
    IO.inspect(binding())
    factorial(n - 1, acc * n)
  end
end

IO.inspect("Factoial of 5 #{Recursive.factorial(5, 1)}")
IO.puts("####################")
IO.inspect("Factoial of 15 #{Recursive.factorial(15, 1)}")
IO.puts("####################")
IO.inspect("Factoial of 5 #{Recursive.factorial(45, 1)}")
