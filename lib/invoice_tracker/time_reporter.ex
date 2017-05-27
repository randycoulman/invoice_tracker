defmodule InvoiceTracker.TimeReporter do
  @moduledoc """
  Formats a time summary into an ASCII table
  """

  alias Number.Delimit
  alias TableRex.Table
  alias Timex.Duration

  def format_summary(%{total: total, rate: rate, projects: projects}) do
    projects
    |> Enum.map(&(project_row(&1, rate)))
    |> Table.new
    |> Table.put_header(["Hours", "Project", "Rate", "Amount"])
    |> Table.put_header_meta(0..3, align: :center)
    |> Table.put_column_meta([0, 2, 3], align: :right)
    |> Table.add_row(total_row(total, rate))
    |> Table.render!
    |> add_footer_separator
  end

  defp project_row(%{name: name, time: time}, rate) do
    [format_hours(time), name, rate, format_amount(time, rate)]
  end

  defp total_row(total, rate) do
    [format_hours(total), "TOTAL", "", format_amount(total, rate)]
  end

  defp add_footer_separator(table) do
    rows = String.split(table, "\n")
    separator = List.first(rows)
    rows
    |> List.insert_at(-4, separator)
    |> Enum.join("\n")
  end

  defp format_hours(duration) do
    duration
    |> Duration.to_hours
    |> Delimit.number_to_delimited(precision: 1)
  end

  defp format_amount(duration, rate) do
    duration
    |> Duration.to_hours
    |> Float.round(1)
    |> Kernel.*(rate)
    |> Delimit.number_to_delimited(precision: 2)
  end
end
