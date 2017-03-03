defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date]
end

defimpl String.Chars, for: InvoiceTracker.Invoice do
  def to_string(invoice) do
    "##{invoice.number} on #{invoice.date} for $#{invoice.amount}"
  end
end
