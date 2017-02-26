defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date]
  @type t :: %__MODULE__{number: integer, amount: float, date: Date.t}
end

defimpl String.Chars, for: InvoiceTracker.Invoice do
  @spec to_string(InvoiceTracker.Invoice.t) :: String.t
  def to_string(invoice) do
    "##{invoice.number} on #{invoice.date} for $#{invoice.amount}"
  end
end
