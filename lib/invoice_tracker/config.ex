defmodule InvoiceTracker.Config do
  @moduledoc """
  Process a configuration file and return a map containing the config settings.
  """

  def read io do
    io
    |> IO.stream(:line)
    |> Enum.map(&read_line/1)
    |> Enum.reduce(%{}, &(Map.merge(&2, &1)))
  end

  defp read_line line do
    case String.split(line, ~r{\s*=\s*}, parts: 2) do
      [_] ->
        %{}
      [key, value] ->
        %{String.to_atom(String.trim(key)) => String.trim(value)}
    end
  end
end
