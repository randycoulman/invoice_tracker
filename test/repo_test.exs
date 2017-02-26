defmodule RepoTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.Invoice
  alias InvoiceTracker.Repo

  setup do
    Repo.start_link(fn -> :ets.new(__MODULE__, []) end)
    :ok
  end

  describe "storing an invoice" do
    test "stores the invoice by number" do
      invoice = %Invoice{number: 42, date: ~D{2017-01-16}, amount: 1250.34}

      Repo.store(invoice)

      assert Repo.find(invoice.number) == {:ok, invoice}
    end
  end
end
