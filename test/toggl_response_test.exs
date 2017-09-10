defmodule TogglResponseTest do
  @moduledoc false

  use ExUnit.Case

  import ShortMaps

  alias InvoiceTracker.{Detail, TogglResponse}
  alias Timex.Duration

  setup do
    response = %{
      "total_grand" => 123_456_789,
      "data" => [%{
          "title" => %{"project" => "First Project"},
          "time" => 3_456_000,
          "items" => [%{
            "title" => %{"time_entry" => "Entry the First"},
            "time" => 1_234_000
          }, %{
            "title" => %{"time_entry" => "Entry the Second"},
            "time" => 2_222_000
          }]
        }, %{
          "title" => %{"project" => "Other Project"},
          "time" => 120_000_789,
          "items" => [%{
            "title" => %{"time_entry" => "Solo"},
            "time" => 120_000_789
          }]
        }
      ]
    }
    summary = TogglResponse.to_summary(response)
    {:ok, summary: summary}
  end

  test "reads total time", ~m{summary}a do
    assert summary.total == Duration.from_milliseconds(123_456_789)
  end

  test "extracts project time entries", ~m{summary}a do
    projects = Enum.map(summary.projects, &(Map.take(&1, [:name, :time])))
    assert projects == [
      %{
        name: "First Project",
        time: Duration.from_milliseconds(3_456_000)
      },
      %{
        name: "Other Project",
        time: Duration.from_milliseconds(120_000_789)
      }
    ]
  end

  test "extracts activity details", ~m{summary}a do
    assert Enum.flat_map(summary.projects, &(&1.details)) == [
      %Detail{
        activity: "Entry the First",
        time: Duration.from_milliseconds(1_234_000)
      },
      %Detail{
        activity: "Entry the Second",
        time: Duration.from_milliseconds(2_222_000)
      },
      %Detail{
        activity: "Solo",
        time: Duration.from_milliseconds(120_000_789)
      }
    ]
  end
end
