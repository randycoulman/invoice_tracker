defmodule InvoiceTracker.TimeSummary do
  @moduledoc """
  A struct that summarizes time entries for an invoice period.
  """

  alias Timex.Duration

  defstruct total: Duration.zero(), projects: []
end

defmodule InvoiceTracker.ProjectTimeSummary do
  @moduledoc """
  A struct that summarizes time entries for a single project for an
  invoice period.
  """

  alias Timex.Duration

  defstruct name: "", time: Duration.zero()
end
