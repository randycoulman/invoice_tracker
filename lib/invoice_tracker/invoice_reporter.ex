defmodule InvoiceTracker.InvoiceReporter do
  @moduledoc """
  Formats a list of invoices into an ASCII table
  """

  import ShorterMaps

  alias InvoiceTracker.Invoice
  alias Number.Delimit
  alias TableRex.Table

  @doc """
  Generate a tabular list of invoices suitable for human consumption.

  Shows the invoice date and number, along with the amount and whether or not
  the invoice has been paid.
  """
  @spec format_list([Invoice.t()]) :: String.t()
  def format_list([]), do: "No invoices found\n"

  def format_list(invoices) do
    invoices
    |> Enum.map(&format_list_row/1)
    |> Table.new()
    |> Table.put_header(["Date", "#", "Amount", "Paid"])
    |> Table.put_header_meta(0..3, align: :center)
    |> Table.put_column_meta(1..2, align: :right)
    |> Table.render!()
  end

  defp format_list_row(~M{%Invoice date, number, amount, paid_on}) do
    [date, number, format_amount(amount), paid_on]
  end

  @doc """
  Generate a tabular invoice status report suitable for human consumption.

  Shows the invoice date and number, along with the amount, due date, payment
  date (if paid), and status as of the report date.
  """
  @spec format_status([Invoice.t()], Date.t()) :: String.t()
  def format_status([], _date), do: "No active invoices\n"

  def format_status(invoices, date) do
    invoices
    |> Enum.map(&format_status_row(&1, date))
    |> Table.new()
    |> Table.put_title("Invoice status as of #{date}")
    |> Table.put_header(["Date", "#", "Amount", "Due", "Paid", "Status"])
    |> Table.put_header_meta(0..5, align: :center)
    |> Table.put_column_meta(1..2, align: :right)
    |> Table.render!()
  end

  defp format_status_row(invoice, date) do
    [
      invoice.date,
      invoice.number,
      format_amount(invoice.amount),
      Invoice.due_on(invoice),
      invoice.paid_on,
      Invoice.status(invoice, date)
    ]
  end

  defp format_amount(amount) do
    Delimit.number_to_delimited(amount)
  end
end
