defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date, :paid_on]

  def paid?(invoice), do: !!invoice.paid_on
  def pay(invoice, date), do: %{invoice | paid_on: date}
end
