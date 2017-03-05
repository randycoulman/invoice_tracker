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
  Find an invoice by its number.
  """
  def lookup(number) do
    {:ok, invoice} = Repo.find(number)
    invoice
  end

  @doc """
  Record an invoice.
  """
  def record(invoice), do: Repo.store(invoice)

  @doc """
  Mark an invoice as paid.
  """
  def pay(number, date) do
    Repo.update(number, fn(invoice) -> %{invoice | paid_on: date} end)
  end
end
