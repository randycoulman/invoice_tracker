defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date, :paid_on]

  def paid?(%{paid_on: nil}), do: false
  def paid?(_), do: true

  def pay(invoice, date), do: %{invoice | paid_on: date}
end
