defmodule InvoiceTracker.CLI do
  @moduledoc """
  Defines the command-line interface
  """

  use ExCLI.DSL, escript: true

  alias ExCLI.Argument

  alias InvoiceTracker.{
    Config,
    DefaultDate,
    Invoice,
    InvoiceReporter,
    Repo,
    Rounding,
    TimeReporter,
    TimeSummary,
    TimeTracker
  }

  @config_file "~/.invoicerc"
  @default_invoice_file "invoices.ets"

  name "invoice"
  description "Invoice tracker"

  long_description ~s"""
  invoice records invoices and payments and produces a report of
  paid and unpaid invoices.
  """

  option :file,
    help: "The invoice data file to use",
    aliases: [:f]

  command :record do
    aliases [:rec, :r]
    description "Records an invoice"

    argument :amount, type: :float

    option :date,
      help: "The invoice date",
      aliases: [:d],
      process: &__MODULE__.process_date_option/3

    option :number,
      help: "The invoice number (default is next highest number)",
      aliases: [:n],
      type: :integer

    run initial_context do
      config()
      |> Map.merge(initial_context)
      |> record_invoice
    end
  end

  defp record_invoice(context) do
    start_repo(context)

    invoice = %Invoice{
      number: context[:number] || InvoiceTracker.next_invoice_number(),
      amount: context.amount,
      date: context[:date] || DefaultDate.for_invoice()
    }

    InvoiceTracker.record(invoice)
  end

  command :generate do
    aliases [:gen, :g]
    description "Generates an invoice (eventually)"

    option :api_token,
      help: "The Toggl API token to use",
      aliases: [:t]

    option :workspace_id,
      help: "The id of the workspace containing the time entries",
      aliases: [:w]

    option :client_id,
      help: "The id of the client to invoice",
      aliases: [:c]

    option :date,
      help: "The invoice date",
      aliases: [:d],
      process: &__MODULE__.process_date_option/3

    option :number,
      help: "The invoice number (default is next highest number)",
      aliases: [:n],
      type: :integer

    option :rate,
      help: "The hourly rate to charge",
      aliases: [:r]

    option :save,
      help: "Record the generated invoice",
      aliases: [:s],
      type: :boolean,
      default: false

    run initial_context do
      context = Map.merge(config(), initial_context)
      summary = context |> time_summary |> TimeSummary.rounded()
      rate = String.to_integer(context.rate)
      show_summary(summary, rate)

      if context.save do
        amount = Rounding.charge(summary.total, rate)
        record_invoice(Map.put(context, :amount, amount))
      end
    end
  end

  defp time_summary(context) do
    InvoiceTracker.time_summary(
      TimeTracker.client(context.api_token),
      invoice_date: context[:date] || DefaultDate.for_invoice(),
      workspace_id: context.workspace_id,
      client_id: context.client_id
    )
  end

  defp show_summary(summary, rate) do
    summary
    |> TimeReporter.format_summary(rate: rate)
    |> IO.write()

    IO.puts("")

    summary
    |> TimeReporter.format_details()
    |> IO.write()
  end

  command :payment do
    aliases [:pay, :p]
    description "Records a payment"

    option :number,
      help: "The invoice number (default: oldest unpaid)",
      aliases: [:n],
      type: :integer

    option :date,
      help: "The invoice date (default: today)",
      aliases: [:d],
      process: &__MODULE__.process_date_option/3

    run initial_context do
      context = Map.merge(config(), initial_context)
      start_repo(context)
      number = Map.get(context, :number, InvoiceTracker.oldest_unpaid_invoice().number)
      InvoiceTracker.pay(number, context[:date] || DefaultDate.for_payment())
    end
  end

  command :list do
    aliases [:ls, :l]
    description "List invoices"

    option :all,
      help: "List all invoices (default: show unpaid only)",
      aliases: [:a],
      default: false,
      type: :boolean

    run initial_context do
      context = Map.merge(config(), initial_context)
      start_repo(context)

      context.all
      |> selected_invoices
      |> Enum.sort_by(& &1.number)
      |> InvoiceReporter.format_list()
      |> IO.write()
    end
  end

  defp selected_invoices(true), do: InvoiceTracker.all()
  defp selected_invoices(_), do: InvoiceTracker.unpaid()

  command :status do
    aliases [:stat, :st, :s]
    description "Show an invoice status report"

    option :date,
      help: "Show status as of this date (default: most recent Friday)",
      aliases: [:d],
      process: &__MODULE__.process_date_option/3

    option :since,
      help: "Include activity since this date (default: 1 week ago)",
      aliases: [:s],
      process: &__MODULE__.process_date_option/3

    run initial_context do
      context = Map.merge(config(), initial_context)
      start_repo(context)
      date = context[:date] || DefaultDate.for_current_status()
      since = context[:since] || DefaultDate.for_previous_status(date)

      since
      |> InvoiceTracker.active_since()
      |> Enum.sort_by(& &1.number)
      |> InvoiceReporter.format_status(date)
      |> IO.write()
    end
  end

  @doc false
  @spec process_date_option(ExCLI.Argument.t(), map, [String.t()]) ::
          {:ok, map, [String.t()]} | {:error, atom, Keyword.t()}
  def process_date_option(option, context, [{:arg, value} | rest]) do
    date = Date.from_iso8601!(value)
    {:ok, Map.put(context, Argument.key(option), date), rest}
  end

  defp config do
    case File.open(Path.expand(@config_file), [:read], &Config.read/1) do
      {:ok, res} ->
        res

      {:error, :enoent} ->
        %{}

      {:error, reason} ->
        IO.puts("Unable to read config file #{@config_file}: #{reason}")
        Process.exit(self(), reason)
    end
  end

  defp start_repo(context) do
    file = Path.expand(context[:file] || @default_invoice_file)
    Repo.start_link_with_file(file)
  end
end
