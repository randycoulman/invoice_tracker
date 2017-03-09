defmodule InvoiceTracker.CLI do
  @moduledoc """
  Defines the command-line interface
  """

  use ExCLI.DSL, escript: true

  alias InvoiceTracker.{DefaultDate, Invoice, Repo, TableFormatter}

  name "invoice"
  description "Invoice tracker"
  long_description ~s"""
  invoice records invoices and payments and produces a report of
  paid and unpaid invoices.
  """

  option :file,
    help: "The invoice data file to use",
    aliases: [:f],
    default: "invoices.ets",
    required: true

  command :record do
    description "Records an invoice"

    argument :number, type: :integer
    argument :amount, type: :float
    option :date,
      help: "The invoice date",
      aliases: [:d],
      default: DefaultDate.for_invoice(),
      required: true

    run context do
      start_repo(context)
      invoice = struct(Invoice, context)
      InvoiceTracker.record(invoice)
    end
  end

  command :payment do
    description "Records a payment"

    argument :number, type: :integer
    option :date,
      help: "The invoice date",
      aliases: [:d],
      required: true

    run context do
      start_repo(context)
      InvoiceTracker.pay(context.number, context.date)
    end
  end

  command :list do
    run context do
      start_repo(context)
      InvoiceTracker.all()
      |> Enum.sort_by(&(&1.number))
      |> TableFormatter.format
      |> IO.write
    end
  end

  defp start_repo(context) do
    Repo.start_link_with_file(context.file)
  end
end
