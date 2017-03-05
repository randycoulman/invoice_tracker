defmodule InvoiceTrackerTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{Invoice, Repo}

  setup do
    Repo.start_link_in_memory()
    {:ok, invoice: %Invoice{number: 42, date: ~D{2017-01-16}, amount: 1250.34}}
  end

  # doctest InvoiceTracker

  describe "recording an invoice" do
    test "it remembers the invoice", %{invoice: invoice} do
      InvoiceTracker.record(invoice)
      assert InvoiceTracker.lookup(invoice.number) == invoice
    end
  end

  describe "listing all invoices" do
    test "includes all recorded invoices", %{invoice: invoice} do
      other_invoice = %Invoice{number: 46, date: ~D{2017-03-16}, amount: 789.54}
      Repo.store(invoice)
      Repo.store(other_invoice)
      all = Repo.all()

      assert(invoice in all)
      assert(other_invoice in all)
    end
  end
end
