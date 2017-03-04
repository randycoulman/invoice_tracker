defmodule InvoiceTracker.Repo do
  @moduledoc """
  Manages the storage of invoices
  """

  @agent __MODULE__

  def start_link_in_memory do
    start_link(fn -> {:ets, :ets.new(__MODULE__, [])} end)
  end

  def start_link_with_file(filename) do
    {:ok, table} = :dets.open_file(filename, [access: :read_write])
    start_link(fn -> {:dets, table} end)
  end

  defp start_link(factory) do
    Agent.start_link(factory, name: @agent)
  end

  def store(invoice), do: Agent.update(@agent, &do_store(&1, invoice))

  defp do_store({storage, table}, invoice) do
    storage.insert(table, {key(invoice), invoice})
    {storage, table}
  end

  def find(number), do: Agent.get(@agent, &do_find(&1, number))

  defp do_find({storage, table}, number) do
    case storage.lookup(table, number) do
      [] -> {:error, :no_such_invoice}
      [{_, invoice}] -> {:ok, invoice}
    end
  end

  def all, do: Agent.get(@agent, &do_all/1)

  defp do_all({storage, table}) do
    storage.foldr(fn {_, invoice}, list -> [invoice | list] end, [], table)
  end

  defp key(invoice), do: invoice.number
end
