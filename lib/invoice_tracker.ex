defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  @doc """
  Record an invoice.
  """
  @spec record(Repo.t, Invoice.t) :: :ok
  def record(repo, invoice), do: repo.store(invoice)
end
