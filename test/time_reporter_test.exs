defmodule TimeReporterTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{ProjectTimeSummary, TimeReporter, TimeSummary}
  alias Timex.Duration

  describe "time summary" do
    test "nicely formats the summary" do
      summary = %TimeSummary{
        total: Duration.from_minutes(676),
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
      +-----------------+-------+
      | Project         | Hours |
      +-----------------+-------+
      | First Project   |   7.4 |
      | Another Project |   3.9 |
      +-----------------+-------+
      | TOTAL           |  11.3 |
      +-----------------+-------+
      """
    end
  end
end
