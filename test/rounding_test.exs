defmodule RoundingTest do
  @moduledoc false

  use ExUnit.Case

  alias InvoiceTracker.Rounding
  alias Timex.Duration

  describe "basic rounding" do
    test "rounds down to nearest tenth of an hour" do
      assert round_minutes(74.9) === 1.2
    end

    test "rounds up to nearest tenth of an hour" do
      assert round_minutes(135) === 2.3
    end
  end

  describe "computing charges" do
    test "rounds to nearest tenth before calculating" do
      assert Rounding.charge(Duration.from_minutes(118), 100) == 200
    end
  end

  describe "reconciling entries" do
    test "rounds entries with no adjustments needed" do
      assert reconcile([14.9, 15], 0.5) == [0.2, 0.3]
    end

    test "rounds nearest-to-rounding-up entry up to match total" do
      assert reconcile([20.8, 8.9], 0.5) == [0.3, 0.2]
    end

    test "rounds nearest-to-rounding-down entry down to match total" do
      assert reconcile([21.1, 9.2], 0.5) == [0.3, 0.2]
    end

    test "rounds multiple entries to match total" do
      # Based on a real example: sum of rounded times is 20.1 hrs,
      # but rounded total is 20.3 hrs.
      times = [349.90, 260.08, 152.80, 248.02, 130.23, 74.25]
      assert reconcile(times, 20.3) == [5.8, 4.3, 2.6, 4.1, 2.2, 1.3]
    end
  end

  defp round_minutes(minutes) do
    minutes
    |> Duration.from_minutes
    |> Rounding.round_time
    |> Duration.to_hours
  end

  defp reconcile(times, total) do
    times
    |> Enum.map(&make_entry/1)
    |> Rounding.reconcile(Duration.from_hours(total))
    |> Enum.map(&from_entry/1)
  end

  defp make_entry(time), do: %{time: Duration.from_minutes(time)}

  defp from_entry(entry), do: Duration.to_hours(entry.time)
end
