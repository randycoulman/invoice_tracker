defmodule InvoiceTracker.Invoice do
  @moduledoc """
  A struct for representing individual invoices.
  """
  import ShorterMaps

  defstruct [:number, :amount, :date, :paid_on]

  @type key :: pos_integer
  @type t :: %__MODULE__{
          number: key,
          amount: float,
          date: Date.t(),
          paid_on: Date.t() | nil
        }

  @doc """
  Mark an invoice as paid as of the given date.
  """
  @spec pay(t, Date.t()) :: t
  def pay(invoice, date), do: %{invoice | paid_on: date}

  @doc """
  Answer whether or not an voice has been paid.
  """
  @spec paid?(t) :: boolean
  def paid?(%__MODULE__{paid_on: nil}), do: false
  def paid?(_), do: true

  @doc """
  Return the due date for the invoice
  """
  @spec due_on(t) :: Date.t()
  def due_on(invoice), do: Timex.shift(invoice.date, days: 15)

  @doc """
  Determine if an invoice has had any activity since a given date.

  An invoice is active if it hasn't been paid yet, or if it was issued and/or
  paid after the date.
  """
  @spec active_since?(t, Date.t()) :: boolean
  def active_since?(invoice, date) do
    !paid?(invoice) || Timex.before?(date, last_activity(invoice))
  end

  defp last_activity(~M{%__MODULE__ paid_on: nil, date}), do: date
  defp last_activity(invoice), do: invoice.paid_on

  @doc """
  Report on the status of an invoice as of a date.

  An invoice might be late (response indicates how many days late), current, or
  paid on time.
  """
  @spec status(t, Date.t()) :: String.t()
  def status(invoice, date) do
    status_date = invoice.paid_on || date
    days_late = Timex.diff(status_date, due_on(invoice), :days)
    do_status(paid?(invoice), days_late)
  end

  defp do_status(_, 1), do: "1 day late"
  defp do_status(_, days_late) when days_late > 0, do: "#{days_late} days late"
  defp do_status(false, _), do: "Current"
  defp do_status(_, _), do: "Paid on time"
end
