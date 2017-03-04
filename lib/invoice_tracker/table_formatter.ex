defmodule InvoiceTracker.TableFormatter do
  @moduledoc """
  Formats a list of invoices into an ASCII table
  """

  alias InvoiceTracker.Invoice
  alias Number.Delimit
  alias TableRex.Table

  def format([]), do: "No invoices found\n"
  def format(invoices) do
    invoices
    |> Enum.map(&format_row/1)
    |> Table.new
    |> Table.put_header(["Date", "#", "Amount"])
    |> Table.put_header_meta(0..2, align: :center)
    |> Table.put_column_meta(1..2, align: :right)
    |> Table.render!
  end

  defp format_row(%Invoice{date: date, number: number, amount: amount}) do
    [date, number, Delimit.number_to_delimited(amount)]
  end
end
