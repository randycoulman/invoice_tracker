defmodule InvoiceTracker.TimeReporter do
  @moduledoc """
  Formats a time summary into an ASCII table
  """

  alias Number.Delimit
  alias TableRex.Table
  alias Timex.Duration

  def format_summary(%{total: total, projects: projects}) do
    projects
    |> Enum.map(&project_row/1)
    |> Table.new
    |> Table.put_column_meta(1, align: :right)
    |> Table.put_header(["Project", "Hours"])
    |> Table.add_row(["", ""])
    |> Table.add_row(["TOTAL", format_hours(total)])
    |> Table.render!
  end

  defp project_row(%{name: name, time: time}) do
    [name, format_hours(time)]
  end

  defp format_hours(duration) do
    duration
    |> Duration.to_hours
    |> Delimit.number_to_delimited(precision: 1)
  end
end
