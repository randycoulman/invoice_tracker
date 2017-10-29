defmodule TimeReporterTest do
  @moduledoc false

  use ExUnit.Case

  import ShorterMaps

  alias InvoiceTracker.{Detail, ProjectTimeSummary, TimeReporter, TimeSummary}
  alias Timex.Duration

  describe "time summary" do
    setup do
      summary = %TimeSummary{
        total: Duration.from_minutes(676),
        projects: [
          %ProjectTimeSummary{
            name: "First Project",
            time: Duration.from_minutes(444),
            details: [
              %Detail{activity: "Activity 1", time: Duration.from_minutes(126)},
              %Detail{activity: "Activity 2", time: Duration.from_minutes(318)}
            ]
          },
          %ProjectTimeSummary{
            name: "Another Project",
            time: Duration.from_minutes(232),
            details: [
              %Detail{
                activity: "All the things", time: Duration.from_minutes(232)
              }
            ]
          }
        ]
      }
      {:ok, [summary: summary]}
    end

    test "nicely formats the summary", ~M{summary} do
      output = TimeReporter.format_summary(summary, rate: 100)
      assert output == """
      +-------+-----------------+------+----------+
      | Hours |     Project     | Rate |  Amount  |
      +-------+-----------------+------+----------+
      |   7.4 | First Project   |  100 |   740.00 |
      |   3.9 | Another Project |  100 |   390.00 |
      +-------+-----------------+------+----------+
      |  11.3 | TOTAL           |      | 1,130.00 |
      +-------+-----------------+------+----------+
      """
    end

    test "nicely formats the details", ~M{summary} do
      output = TimeReporter.format_details(summary)
      assert output == ~S"""
      ## Included

      ### First Project

      - Activity 1 (2.1 hrs)

      - Activity 2 (5.3 hrs)

      ### Another Project

      - All the things (3.9 hrs)
      """
    end
  end
end
