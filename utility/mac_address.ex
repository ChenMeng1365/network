
defmodule MacAddress do
  def format numbers do
    numbers
    |> Enum.map( &Integer.to_string(&1,16) )
    |> Enum.map( fn(x) -> case String.length(x) do 1 -> "0"<>x ;2 -> x end end)
    |> Enum.join(":")
  end
end