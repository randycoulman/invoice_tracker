defmodule InvoiceTracker.TimeTracker do
  @moduledoc """
  Retrieves time entry data from a time-tracking service
  """

  alias InvoiceTracker.{TimeSummary, TogglResponse}

  use Tesla, only: [:get], docs: false

  @type tracker :: Tesla.Client.t()

  @type option ::
          {:start_date, Date.t()}
          | {:end_date, Date.t()}
          | {:workspace_id, String.t()}
          | {:client_id, String.t()}

  plug(Tesla.Middleware.BaseUrl, "https://www.toggl.com/reports/api/v2")
  plug(Tesla.Middleware.Query, user_agent: "https://github.com/randycoulman/invoice_tracker")
  plug(Tesla.Middleware.JSON)

  @doc """
  Returns an authenticated client for the time-tracking service.

  This client can then be passed to `summary/2` in order to retrieve a time
  summary.
  """
  @spec client(String.t()) :: tracker
  def client(api_token) do
    encoded_token = Base.encode64("#{api_token}:api_token")

    Tesla.build_client([
      {Tesla.Middleware.Headers, %{"Authorization" => "Basic #{encoded_token}"}}
    ])
  end

  @doc """
  Retrieve a summary report from the time-tracking service.

  - `time_tracker` is an authenticated client for the time-tracking service,
    created with `client/1`.
  """
  @spec summary(tracker, [option]) :: TimeSummary.t()
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
    |> Map.get(:body)
    |> TogglResponse.to_summary()
  end
end
