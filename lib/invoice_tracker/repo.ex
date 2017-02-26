defmodule InvoiceTracker.Repo do
  @moduledoc """
  Manages the storage of invoices
  """

  @agent __MODULE__

  alias InvoiceTracker.Invoice

  @type table_factory :: (() -> :ets.tid())

  @spec start_link(table_factory) :: Agent.onstart()
  def start_link(factory) do
    Agent.start_link(factory, name: @agent)
  end

  @spec store(Invoice.t) :: :ok
  def store(invoice), do: Agent.update(@agent, &do_store(&1, invoice))

  @spec find(integer) :: {:ok, Invoice.t} | {:error, atom}
  def find(number), do: Agent.get(@agent, &do_find(&1, number))

  defp do_store(table, invoice) do
    :ets.insert(table, {key(invoice), invoice})
    table
  end

  defp do_find(table, number) do
    case :ets.lookup(table, number) do
      [] -> {:error, :no_such_invoice}
      [{_, invoice}] -> {:ok, invoice}
    end
  end

  defp key(invoice), do: invoice.number
end
