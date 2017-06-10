defmodule InvoiceTracker.TimeSummary do
  @moduledoc """
  A struct that summarizes time entries for an invoice period.
  """

  alias InvoiceTracker.{ProjectTimeSummary, Rounding}
  alias Timex.Duration

  defstruct total: Duration.zero(), projects: []

  @doc """
  Rounds all of the times in the summary to the nearest tenth of an hour.

  Also reconciles project and detail entries so that, when rounded, they add
  up to the total (rounded) time.

  A TimeSummary should be rounded before reporting on it or generating an
  invoice for it.
  """
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

  @doc """
  Reconciles a list of projects with a rounded total time.

  Times are rounded to the nearest tenth of an hour and then adjusted so that,
  when rounded, they add up to the total (rounded) time.

  Each project's details are also reconciled and rounded in the same way once
  the projects themselves have been reconciled and rounded.
  """
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

  @doc """
  Reconciles a list of detail entries with a rounded total time.

  Times are rounded to the nearest tenth of an hour and then adjusted so that,
  when rounded, they add up to the total (rounded) time.
  """
  def reconciled(details, total), do: Rounding.reconcile(details, total)
end
