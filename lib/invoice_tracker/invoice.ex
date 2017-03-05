defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date, :paid_on]
end
