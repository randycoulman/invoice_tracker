defmodule InvoiceTracker.TimeSummary do
  @moduledoc """
  A struct that summarizes time entries for an invoice period.
  """

  alias InvoiceTracker.{ProjectTimeSummary, Rounding}
  alias Timex.Duration

  defstruct total: Duration.zero(), rate: 0, projects: []

  def rounded(summary) do
    summary
    |> Map.update!(:total, &Rounding.round_time/1)
    |> reconcile_projects
  end

  defp reconcile_projects(summary) do
    Map.update!(summary, :projects,
      &(ProjectTimeSummary.reconciled(&1, summary.total))
    )
  end
end

defmodule InvoiceTracker.ProjectTimeSummary do
  @moduledoc """
  A struct that summarizes time entries for a single project for an
  invoice period.
  """

  alias InvoiceTracker.{Detail, Rounding}
  alias Timex.Duration

  defstruct name: "", time: Duration.zero(), details: []

  def reconciled(projects, total) do
    projects
    |> Rounding.reconcile(total)
    |> Enum.map(&reconcile_details/1)
  end

  defp reconcile_details(project) do
    Map.update!(project, :details, &(Detail.reconciled(&1, project.time)))
  end
end

defmodule InvoiceTracker.Detail do
  @moduledoc """
  A struct that represents a project activity detail entry for an
  invoice period.
  """

  alias InvoiceTracker.Rounding
  alias Timex.Duration

  defstruct activity: "", time: Duration.zero()

  def reconciled(details, total), do: Rounding.reconcile(details, total)
end
