defmodule TimeSummaryTest do
  @moduledoc false

  use ExUnit.Case

  import ShortMaps

  alias InvoiceTracker.{Detail, ProjectTimeSummary, TimeSummary}
  alias Timex.Duration

  setup do
    summary = %TimeSummary{
      total: Duration.from_minutes(464),
      projects: [
        %ProjectTimeSummary{
          name: "First Project",
          time: Duration.from_minutes(249),
          details: [
            %Detail{activity: "Activity 1", time: Duration.from_minutes(81)},
            %Detail{activity: "Activity 2", time: Duration.from_minutes(168)}
          ]
        },
        %ProjectTimeSummary{
          name: "Another Project",
          time: Duration.from_minutes(215),
          details: [
            %Detail{
              activity: "All the things", time: Duration.from_minutes(215)
            }
          ]
        }
      ]
    } |> TimeSummary.rounded
    {:ok, [summary: summary]}
  end

  describe "rounding" do
    test "rounds total hours", ~m{summary}a do
      assert Duration.to_hours(summary.total) == 7.7
    end

    test "rounds and adjusts project hours to match total",
      %{summary: ~m{projects}a} do
        assert Enum.map(projects, &(Duration.to_hours(&1.time))) == [4.1, 3.6]
    end

    test "rounds and adjusts detail hours to match rounded project total",
      %{summary: ~m{projects}a} do
      assert Enum.flat_map(projects, fn project ->
        Enum.map(project.details, &(Duration.to_hours(&1.time)))
      end) === [1.3, 2.8, 3.6]
    end
  end
end
