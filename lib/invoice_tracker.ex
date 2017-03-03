defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  alias InvoiceTracker.Repo

  @doc """
  Record an invoice.
  """
  def record(invoice, repo \\ Repo), do: repo.store(invoice)
end
