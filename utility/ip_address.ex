
defmodule IPv4Address do
  def format numbers do
    numbers
    |> Enum.join(".")
  end
end
