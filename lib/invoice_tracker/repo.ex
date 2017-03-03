defmodule InvoiceTracker.Repo do
  @moduledoc """
  Manages the storage of invoices
  """

  @agent __MODULE__

  alias InvoiceTracker.Invoice

  def start_link(factory) do
    Agent.start_link(factory, name: @agent)
  end

  def store(invoice), do: Agent.update(@agent, &do_store(&1, invoice))

  def find(number), do: Agent.get(@agent, &do_find(&1, number))

  defp do_store({storage, table}, invoice) do
    storage.insert(table, {key(invoice), invoice})
    {storage, table}
  end

  defp do_find({storage, table}, number) do
    case storage.lookup(table, number) do
      [] -> {:error, :no_such_invoice}
      [{_, invoice}] -> {:ok, invoice}
    end
  end

  defp key(invoice), do: invoice.number
end
