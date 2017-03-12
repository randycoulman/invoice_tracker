defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """

  defstruct [:number, :amount, :date, :paid_on]

  def pay(invoice, date), do: %{invoice | paid_on: date}

  def paid?(%{paid_on: nil}), do: false
  def paid?(_), do: true

  def due_on(invoice), do: Timex.shift(invoice.date, days: 15)

  def active_since?(invoice, date) do
    !paid?(invoice) || Timex.compare(date, last_activity(invoice)) < 0
  end

  defp last_activity(invoice) do
    invoice.paid_on || invoice.date
  end

  def status(invoice, date) do
    status_date = invoice.paid_on || date
    days_late = Timex.diff(status_date, due_on(invoice), :days)
    do_status(paid?(invoice), days_late)
  end

  defp do_status(_, days_late) when days_late > 0, do: "#{days_late} days late"
  defp do_status(false, _), do: "Current"
  defp do_status(_, _), do: "Paid on time"
end
