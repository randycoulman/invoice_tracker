defmodule TogglResponseTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{ProjectTimeSummary, TogglResponse}
  alias Timex.Duration

  setup do
    response = %{
      "total_grand" => 123_456_789,
      "data" => [%{
          "title" => %{"project" => "First Project"},
          "time" => 3_456_000
        }, %{
          "title" => %{"project" => "Other Project"},
          "time" => 120_000_789
        }
      ]
    }
    summary = TogglResponse.to_summary(response)
    {:ok, summary: summary}
  end

  test "reads total time", %{summary: summary} do
    assert summary.total == Duration.from_milliseconds(123_456_789)
  end

  test "extracts project time entries", %{summary: summary} do
    assert summary.projects == [
      %ProjectTimeSummary{
        name: "First Project", time: Duration.from_milliseconds(3_456_000)
        },
      %ProjectTimeSummary{
        name: "Other Project", time: Duration.from_milliseconds(120_000_789)
      }
    ]
  end
end
