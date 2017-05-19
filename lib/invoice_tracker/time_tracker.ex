defmodule InvoiceTracker.TimeTracker do
  @moduledoc """
  Retrieves time entry data from a time-tracking service
  """

  alias InvoiceTracker.{ProjectTimeSummary, TimeSummary}
  alias Timex.Duration

  use Tesla, only: [:get], docs: false

  plug Tesla.Middleware.BaseUrl, "https://www.toggl.com/reports/api/v2"
  plug Tesla.Middleware.Query, [
    user_agent: "https://github.com/randycoulman/invoice_tracker"
  ]
  plug Tesla.Middleware.JSON

  def client(api_token) do
    encoded_token = Base.encode64("#{api_token}:api_token")
    Tesla.build_client [
      {Tesla.Middleware.Headers, %{"Authorization" => "Basic #{encoded_token}"}}
    ]
  end

  def summary(
    time_tracker,
    start_date: start_date,
    end_date: end_date,
    workspace_id: workspace_id,
    client_id: client_id
  ) do
    query = [
      workspace_id: workspace_id,
      client_ids: client_id,
      since: Date.to_iso8601(start_date),
      until: Date.to_iso8601(end_date)
    ]
    time_tracker
    |> get("/summary", query: query)
    |> process_response
  end

  defp process_response(%{body: response}) do
    total = to_duration(response["total_grand"])
    projects = Enum.map(response["data"], &to_project/1)

    %TimeSummary{total: total, projects: projects}
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
