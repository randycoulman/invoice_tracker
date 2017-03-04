defmodule RepoTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{Invoice, Repo}

  setup do
    Repo.start_link_in_memory()
    :ok
  end

  describe "storing an invoice" do
    test "stores the invoice by number" do
      invoice = %Invoice{number: 42, date: ~D{2017-01-16}, amount: 1250.34}

      Repo.store(invoice)

      assert Repo.find(invoice.number) == {:ok, invoice}
    end
  end

  describe "listing all invoices" do
    test "includes all recorded invoices" do
      invoice1 = %Invoice{number: 42, date: ~D{2017-01-16}, amount: 1250.34}
      invoice2 = %Invoice{number: 46, date: ~D{2017-03-16}, amount: 789.54}
      Repo.store(invoice1)
      Repo.store(invoice2)
      all = Repo.all()

      assert(invoice1 in all)
      assert(invoice2 in all)
    end
  end
end
