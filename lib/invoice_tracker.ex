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
  Return a list of all unpaid invoices
  """
  def unpaid do
    all()
    |> Enum.reject(&Invoice.paid?/1)
  end

  @doc """
  Return a list of all invoices that were active after a given date.

  Active means:
    * Unpaid as of that date
    * Issued since that date
    * Paid since that date
  """
  def active_since(date) do
    all()
    |> Enum.filter(&(Invoice.active_since?(&1, date)))
  end

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
    unpaid()
    |> Enum.sort_by(&(Map.get(&1, :date)), &Timex.before?/2)
    |> List.first
  end

  @doc """
  Return the next available invoice number.
  """
  def next_invoice_number do
    1 + highest_invoice_number()
  end

  defp highest_invoice_number do
    all()
    |> Enum.map(&(&1.number))
    |> Enum.max(fn -> 0 end)
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
