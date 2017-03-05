defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  alias InvoiceTracker.Repo

  @doc """
  Return a list of all invoices
  """
  def all, do: Repo.all()

  @doc """
  Record an invoice.
  """
  def record(invoice), do: Repo.store(invoice)

  @doc """
  Find an invoice by its number.
  """
  def lookup(number) do
    {:ok, invoice} = Repo.find(number)
    invoice
  end
end
