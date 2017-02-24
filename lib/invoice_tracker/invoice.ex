defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date]
  @type t :: %__MODULE__{number: integer, amount: float, date: Date.t}
end
