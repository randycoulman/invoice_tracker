defmodule InvoiceTracker.TimeReporter do
  @moduledoc """
  Report on the time entries that make up an invoice.
  """
  import ShortMaps

  alias InvoiceTracker.{Detail, Rounding, ProjectTimeSummary, TimeSummary}
  alias Number.Delimit
  alias TableRex.Table
  alias Timex.Duration

  @doc """
  Generate a tabular summary of an invoice.

  Reports the time spent on each project, as well as the billing rate and total
  charge.  Also includes a grand total of time and amount.

  This report is suitable for generating the line items on an invoice.
  """
  @spec format_summary(TimeSummary.t, [{:rate, number}]) :: String.t
  def format_summary(~m{%TimeSummary total projects}a, rate: rate) do
    Table.new()
    |> Table.add_rows(project_rows(projects, rate))
    |> Table.put_header(["Hours", "Project", "Rate", "Amount"])
    |> Table.put_header_meta(0..3, align: :center)
    |> Table.put_column_meta([0, 2, 3], align: :right)
    |> Table.add_row(total_row(total, rate))
    |> Table.render!
    |> add_footer_separator
  end

  @doc """
  Report on detailed time entries for an invoice.

  Generates a Markdown-format summary of time spent during an invoice period.

  Entries are separated by project, and each entry shows the title of the time
  entry along with the time spent.

  This report is suitable as a starting point for an e-mail outlining the work
  accomplished during the invoice period.
  """
  @spec format_details(TimeSummary.t) :: String.t
  def format_details(~m{%TimeSummary projects}a) do
    """
    ## Included

    #{projects |> Enum.map(&project_section/1) |> Enum.join("\n\n")}
    """
  end

  defp project_section(project) do
    """
    ### #{project.name}

    #{project.details |> Enum.map(&detail_line/1) |> Enum.join("\n\n")}
    """ |> String.trim_trailing
  end

  defp detail_line(~m{%Detail activity time}a) do
    "- #{activity} (#{format_hours(time)} hrs)"
  end

  defp project_rows(projects, rate) do
    Enum.map(projects, &(project_row(&1, rate)))
  end

  defp project_row(~m{%ProjectTimeSummary name time}a, rate) do
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
    |> Rounding.charge(rate)
    |> Delimit.number_to_delimited(precision: 2)
  end
end
