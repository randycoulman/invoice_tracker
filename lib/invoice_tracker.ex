defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  alias InvoiceTracker.{Invoice, Repo, TimeTracker}

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

  @doc """
  Provide a time entry summary for an invoice.
  """
  def time_summary(time_tracker,
    invoice_date: invoice_date,
    workspace_id: workspace_id,
    client_id: client_id
  ) do
    TimeTracker.summary(
      time_tracker,
      start_date: invoice_start_date(invoice_date),
      end_date: invoice_end_date(invoice_date),
      workspace_id: workspace_id,
      client_id: client_id
    )
  end

  defp invoice_start_date(invoice_date) do
    end_date = invoice_end_date(invoice_date)
    if end_date.day >= 16 do
      %{end_date | day: 16}
    else
      %{end_date | day: 1}
    end
  end

  defp invoice_end_date(invoice_date) do
    Timex.shift(invoice_date, days: -1)
  end
end
