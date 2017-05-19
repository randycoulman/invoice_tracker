defmodule InvoiceTracker.TimeReporter do
  @moduledoc """
  Formats a time summary into an ASCII table
  """

  alias Number.Delimit
  alias Timex.Duration

  def format_summary(%{total: total}) do
    TableRex.quick_render!([
      ["TOTAL", format_hours(total)]
    ])
  end

  defp format_hours(duration) do
    duration
    |> Duration.to_hours
    |> Delimit.number_to_delimited(precision: 1)
  end
end
