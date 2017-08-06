defmodule InvoiceTracker do
  @moduledoc """
  Track invoices and payments.
  """

  alias InvoiceTracker.{Invoice, Repo, TimeSummary, TimeTracker}

  @doc """
  Return a list of all invoices
  """
  @spec all() :: [Invoice.t]
  def all, do: Repo.all()

  @doc """
  Return a list of all unpaid invoices
  """
  @spec unpaid() :: [Invoice.t]
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
  @spec active_since(Date.t) :: [Invoice.t]
  def active_since(date) do
    all()
    |> Enum.filter(&(Invoice.active_since?(&1, date)))
  end

  @doc """
  Find an invoice by its number.
  """
  @spec lookup(Invoice.key) :: Invoice.t
  def lookup(number) do
    {:ok, invoice} = Repo.find(number)
    invoice
  end

  @doc """
  Find the earliest invoice that hasn't yet been paid.
  """
  @spec oldest_unpaid_invoice() :: Invoice.t
  def oldest_unpaid_invoice do
    unpaid()
    |> Enum.sort_by(&(Map.get(&1, :date)), &Timex.before?/2)
    |> List.first
  end

  @doc """
  Return the next available invoice number.
  """
  @spec next_invoice_number() :: Invoice.key
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
  @spec record(Invoice.t) :: :ok
  def record(invoice), do: Repo.store(invoice)

  @doc """
  Mark an invoice as paid.
  """
  @spec pay(Invoice.key, Date.t) :: :ok
  def pay(number, date) do
    Repo.update(number, &(Invoice.pay(&1, date)))
  end

  @doc """
  Provide a time entry summary for an invoice.
  """
  @type option ::
    {:invoice_date, Date.t} |
    {:workspace_id, String.t} |
    {:client_id, String.t}
  @spec time_summary(TimeTracker.tracker, [option]) :: TimeSummary.t
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
