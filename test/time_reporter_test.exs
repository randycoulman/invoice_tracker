defmodule TimeReporterTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{ProjectTimeSummary, TimeReporter, TimeSummary}
  alias Timex.Duration

  describe "time summary" do
    test "nicely formats the summary" do
      summary = %TimeSummary{
        total: Duration.from_minutes(676),
        rate: 100,
        projects: [
          %ProjectTimeSummary{
            name: "First Project",
            time: Duration.from_minutes(444)
          },
          %ProjectTimeSummary{
            name: "Another Project",
            time: Duration.from_minutes(232)
          }
        ]
      }
      output = TimeReporter.format_summary(summary)
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
  end
end
