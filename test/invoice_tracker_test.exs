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
      InvoiceTracker.record(invoice)
      InvoiceTracker.record(other_invoice)
      all = InvoiceTracker.all()

      assert(invoice in all)
      assert(other_invoice in all)
    end
  end

  describe "oldest unpaid invoice" do
    test "returns unpaid invoice with the earliest date", %{invoice: invoice} do
      earlier = %Invoice{number: 41, date: ~D[2017-01-01], amount: 1756.05}
      earliest_but_paid = %Invoice{
        number: 40,
        date: ~D{2016-12-16},
        amount: 1000.00,
        paid_on: ~D{2017-01-18}
      }
      InvoiceTracker.record(invoice)
      InvoiceTracker.record(earliest_but_paid)
      InvoiceTracker.record(earlier)

      assert InvoiceTracker.oldest_unpaid_invoice() == earlier
    end
  end

  describe "recording a payment" do
    test "updates the invoice with the payment date", %{invoice: invoice} do
      InvoiceTracker.record(invoice)
      InvoiceTracker.pay(invoice.number, ~D{2017-02-08})
      updated = %Invoice{
        number: 42,
        date: ~D{2017-01-16},
        amount: 1250.34,
        paid_on: ~D{2017-02-08}
      }
      assert InvoiceTracker.lookup(invoice.number) == updated
    end
  end
end
