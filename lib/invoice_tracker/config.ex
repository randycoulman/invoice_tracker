defmodule InvoiceTracker.Config do
  @moduledoc """
  Process a configuration file and return a map containing the config settings.
  """

  @doc """
  Read a configuration file into a map.

  The configuration file contains lines of `key = value` pairs.
  Blank lines are ignored; there is currently no comment character recognized.
  """
  @spec read(IO.device()) :: %{String.t() => String.t()}
  def read(io) do
    io
    |> IO.stream(:line)
    |> Enum.map(&read_line/1)
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
  end

  defp read_line(line) do
    case String.split(line, ~r{\s*=\s*}, parts: 2) do
      [_] ->
        %{}

      [key, value] ->
        %{String.to_atom(String.trim(key)) => String.trim(value)}
    end
  end
end
