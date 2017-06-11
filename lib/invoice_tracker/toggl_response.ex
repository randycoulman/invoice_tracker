defmodule InvoiceTracker.TogglResponse do
  @moduledoc """
  Process responses from Toggle API calls.
  """

  alias InvoiceTracker.{Detail, ProjectTimeSummary, TimeSummary}
  alias Timex.Duration

  @doc """
  Parse a response from the Toggl API into a TimeSummary.
  """
  @spec to_summary(map) :: TimeSummary.t
  def to_summary(response) do
    %TimeSummary{
      total: to_duration(response["total_grand"]),
      projects: Enum.map(response["data"], &to_project/1)
    }
  end

  defp to_project(entry) do
    %ProjectTimeSummary{
      name: get_in(entry, ["title", "project"]),
      time: to_duration(entry["time"]),
      details: Enum.map(entry["items"], &to_detail/1)
    }
  end

  defp to_detail(item) do
    %Detail{
      activity: get_in(item, ["title", "time_entry"]),
      time: to_duration(item["time"])
    }
  end

  defp to_duration(milliseconds) do
    Duration.from_milliseconds(milliseconds)
  end
end
