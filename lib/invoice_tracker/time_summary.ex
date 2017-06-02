defmodule InvoiceTracker.TimeSummary do
  @moduledoc """
  A struct that summarizes time entries for an invoice period.
  """

  alias Timex.Duration

  defstruct total: Duration.zero(), rate: 0, projects: []
end

defmodule InvoiceTracker.ProjectTimeSummary do
  @moduledoc """
  A struct that summarizes time entries for a single project for an
  invoice period.
  """

  alias Timex.Duration

  defstruct name: "", time: Duration.zero(), details: []
end

defmodule InvoiceTracker.Detail do
  @moduledoc """
  A struct that represents a project activity detail entry for an
  invoice period.
  """

  alias Timex.Duration

  defstruct activity: "", time: Duration.zero()
end
