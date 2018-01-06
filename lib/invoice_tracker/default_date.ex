defmodule InvoiceTracker.DefaultDate do
  @moduledoc """
  Calculate default dates for various events.
  """

  @doc """
  Determine the most recent date when an invoice should be issued.

  Invoice dates are always the 1st or the 16th of the month, so we go back to
  the most-recent of those dates.  However, if "today" is the last day of the
  billing cycle, we jump forward to the next day.  This allows us to prepare
  invoices at the end of the last work-day of the billing cycle.
  """
  @spec for_invoice(Date.t()) :: Date.t()
  def for_invoice(today \\ local_today()) do
    tomorrow = Timex.shift(today, days: 1)

    if tomorrow.day >= 16 do
      %{tomorrow | day: 16}
    else
      %{tomorrow | day: 1}
    end
  end

  @doc """
  Determine the payment date for an invoice; defaults to "today".
  """
  @spec for_payment(Date.t()) :: Date.t()
  def for_payment(today \\ local_today()), do: today

  @doc """
  Determine the date of the current status report.

  Status reports are typically sent on Fridays, so we find the most recent
  Friday.
  """
  @spec for_current_status(Date.t()) :: Date.t()
  def for_current_status(today \\ local_today()) do
    Timex.beginning_of_week(today, :fri)
  end

  @doc """
  Determine the date of the previous status report.

  Status reports are typically every week, so this returns the date one week
  before the current status report date.
  """
  @spec for_previous_status(Date.t()) :: Date.t()
  def for_previous_status(current_status_date) do
    Timex.shift(current_status_date, weeks: -1)
  end

  defp local_today, do: Timex.to_date(Timex.local())
end
