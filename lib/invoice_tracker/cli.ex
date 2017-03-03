defmodule InvoiceTracker.CLI do
  @moduledoc """
  Defines the command-line interface
  """

  use ExCLI.DSL, escript: true

  alias InvoiceTracker.{Invoice, Repo}

  name "invoice"
  description "Invoice tracker"
  long_description ~s"""
  invoice records invoices and payments and produces a report of
  paid and unpaid invoices.
  """

  option :file,
    help: "The invoice data file to use",
    aliases: [:f],
    required: true

  command :record do
    description "Records an invoice"

    argument :number, type: :integer
    argument :amount, type: :float
    option :date,
      help: "The invoice date",
      aliases: [:d],
      required: true

    run context do
      start_repo(context)
      invoice = struct(Invoice, context)
      InvoiceTracker.record(invoice)
      IO.puts("Recorded invoice #{invoice}")
    end
  end

  defp start_repo(context) do
    Repo.start_link_with_file(context.file)
  end
end
