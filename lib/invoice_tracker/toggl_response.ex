defmodule InvoiceTracker.TogglResponse do
  @moduledoc """
  Process responses from Toggle API calls.
  """

  alias InvoiceTracker.{ProjectTimeSummary, TimeSummary}
  alias Timex.Duration

  def to_summary(response) do
    %TimeSummary{
      total: to_duration(response["total_grand"]),
      projects: Enum.map(response["data"], &to_project/1)
    }
  end

  defp to_project(entry) do
    %ProjectTimeSummary{
      name: entry["title"]["project"],
      time: to_duration(entry["time"])
    }
  end

  defp to_duration(milliseconds) do
    Duration.from_milliseconds(milliseconds)
  end
end
