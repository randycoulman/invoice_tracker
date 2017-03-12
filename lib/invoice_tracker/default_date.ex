defmodule InvoiceTracker.DefaultDate do
  @moduledoc """
  Calculate default dates for various events.

  Invoice dates are always the 1st or the 16th of the month, so we go back to
  the most-recent of those dates.  However, if "today" is the last day of the
  billing cycle, we jump forward to the next day.
  """

  def for_invoice(today \\ local_today()) do
    tomorrow = Timex.shift(today, days: 1)
    if tomorrow.day >= 16 do
      %{tomorrow | day: 16}
    else
      %{tomorrow | day: 1}
    end
  end

  def for_payment(today \\ local_today()), do: today

  def for_current_status(today \\ local_today()), do: today

  def for_previous_status(current_status_date) do
    Timex.shift(current_status_date, weeks: -1)
  end

  defp local_today, do: Timex.to_date(Timex.local)
end
