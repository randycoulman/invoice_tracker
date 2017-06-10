defmodule InvoiceTracker.Rounding do
  @moduledoc """
  Rounds times to the nearest tenth of an hour.  Reconciles rounded time entries
  with a total time such that a list of entries, when rounded, will add up to a
  total number of hours, when rounded to the nearest tenth of an hour.

  The basic approach is to figure out how many tenths of an hour need to be
  accounted for (up or down), then choose that number of entries to adjust.

  To find the entries, sort them based on their "rounding weight": how close
  was an entry to rounding up?  For adjusting up, take the entries with the
  highest rounding weight; for adjusting down, take the entries that were
  furthest from rounding up.
  """

  alias Timex.Duration

  def reconcile(entries, total) do
    entries
    |> Enum.map(&rounded/1)
    |> Enum.zip(adjustments(entries, total))
    |> Enum.map(&apply_adjustment/1)
  end

  # This algorithm seems to be more accurate than `Float.round(time, 0.1)`.
  def round_time(time), do: time |> to_tenths |> round |> from_tenths

  defp rounded(entry) do
    Map.update!(entry, :time, &round_time/1)
  end

  defp adjustments(entries, total) do
    Enum.map(
      raw_adjustments(Enum.map(entries, &tenths_in/1), to_tenths(total)),
      &from_tenths/1
    )
  end

  defp apply_adjustment({entry, adjustment}) do
    Map.update!(entry, :time, &(Duration.add(&1, adjustment)))
  end

  defp raw_adjustments([], _), do: []
  defp raw_adjustments(tenths, total) do
    rounded_total = tenths
    |> Enum.map(&Kernel.round/1)
    |> Enum.reduce(&Kernel.+/2)

    total_adjustment = round(total - rounded_total)
    distribute(total_adjustment, tenths)
  end

  defp distribute(total, tenths) do
    Enum.reduce(
      distributions(total, tenths),
      List.duplicate(0, length(tenths)),
      &apply_distribution/2
    )
  end

  defp distributions(0, _), do: []
  defp distributions(total, tenths) do
    tenths
    |> Enum.map(&rounding_weight/1)
    |> Enum.with_index
    |> Enum.sort(&(&1 >= &2))
    |> Enum.take(total)
    |> Enum.map(fn {_, index} -> {index, sign(total)} end)
  end

  defp apply_distribution({index, increment}, list) do
    List.update_at(list, index, &(&1 + increment))
  end

  defp rounding_weight(tenth) do
    tenth |> Kernel.*(1000) |> round |> Kernel.rem(500)
  end

  defp sign(n) when n < 0, do: -1
  defp sign(_), do: 1

  defp tenths_in(entry), do: entry |> Map.get(:time) |> to_tenths

  defp to_tenths(time) do
    time |> Duration.scale(10) |> Duration.to_hours
  end

  defp from_tenths(tenths) do
    tenths |> Duration.from_hours |> Duration.scale(0.1)
  end
end
