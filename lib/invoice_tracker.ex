defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  alias InvoiceTracker.Repo

  @doc """
  Return a list of all invoices
  """
  def all(repo \\ Repo), do: repo.all()

  @doc """
  Record an invoice.
  """
  def record(invoice, repo \\ Repo), do: repo.store(invoice)
end
