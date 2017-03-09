defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  alias InvoiceTracker.{Invoice, Repo}

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
  Find the earliest invoice that hasn't yet been paid.
  """
  def oldest_unpaid_invoice do
    all()
    |> Enum.reject(&Invoice.paid?/1)
    |> Enum.sort_by(&(Map.get(&1, :date)), &older?/2)
    |> List.first
  end

  defp older?(d1, d2) do
    Timex.compare(d1, d2) < 0
  end

  @doc """
  Record an invoice.
  """
  def record(invoice), do: Repo.store(invoice)

  @doc """
  Mark an invoice as paid.
  """
  def pay(number, date) do
    Repo.update(number, &(Invoice.pay(&1, date)))
  end
end
