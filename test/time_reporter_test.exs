defmodule TimeReporterTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{TimeReporter, TimeSummary}
  alias Timex.Duration

  describe "time summary" do
    test "nicely formats the summary" do
      summary = %TimeSummary{total: Duration.from_minutes(76)}
      output = TimeReporter.format_summary(summary)
      assert output == """
      +-------+-----+
      | TOTAL | 1.3 |
      +-------+-----+
      """
    end
  end
end
