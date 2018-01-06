defmodule InvoiceTracker.Repo do
  @moduledoc """
  Manages the storage of invoices
  """

  @agent __MODULE__

  alias InvoiceTracker.Invoice

  @doc """
  Start the repository manager using in-memory term storage.
  """
  @spec start_link_in_memory() :: Agent.on_start()
  def start_link_in_memory do
    start_link(fn -> {:ets, :ets.new(__MODULE__, [])} end)
  end

  @doc """
  Start the repository manager using file-based term storage.
  """
  @spec start_link_with_file(String.t()) :: Agent.on_start()
  def start_link_with_file(filename) do
    {:ok, table} = :dets.open_file(filename, access: :read_write)
    start_link(fn -> {:dets, table} end)
  end

  @spec start_link((() -> term)) :: Agent.on_start()
  defp start_link(factory) do
    Agent.start_link(factory, name: @agent)
  end

  @doc """
  Return all of the stored invoices.
  """
  @spec all() :: [Invoice.t()]
  def all, do: Agent.get(@agent, &do_all/1)

  defp do_all({storage, table}) do
    storage.foldr(fn {_, invoice}, list -> [invoice | list] end, [], table)
  end

  @doc """
  Find an invoice by its number.
  """
  @spec find(Invoice.key()) :: {:ok, Invoice.t()} | {:error, atom}
  def find(number), do: Agent.get(@agent, &do_find(&1, number))

  defp do_find({storage, table}, number) do
    case storage.lookup(table, number) do
      [] -> {:error, :no_such_invoice}
      [{_, invoice}] -> {:ok, invoice}
    end
  end

  @doc """
  Save an invoice into storage.
  """
  @spec store(Invoice.t()) :: :ok
  def store(invoice), do: Agent.update(@agent, &do_store(&1, invoice))

  defp do_store({storage, table}, invoice) do
    storage.insert(table, {key(invoice), invoice})
    {storage, table}
  end

  @doc """
  Update an invoice.

  Finds the invoice by its number, applies the updater function to it, and
  stores the result.
  """
  @spec update(Invoice.key(), (Invoice.t() -> Invoice.t())) :: :ok
  def update(number, updater), do: Agent.update(@agent, &do_update(&1, number, updater))

  defp do_update(state, number, updater) do
    {:ok, invoice} = do_find(state, number)
    do_store(state, updater.(invoice))
  end

  defp key(invoice), do: invoice.number
end
