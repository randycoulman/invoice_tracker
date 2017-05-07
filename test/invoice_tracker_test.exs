defmodule InvoiceTrackerTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{Invoice, Repo}

  setup do
    Repo.start_link_in_memory()
    :ok
  end

  # doctest InvoiceTracker

  describe "recording an invoice" do
    test "it remembers the invoice" do
      invoice = make_invoice()
      InvoiceTracker.record(invoice)
      assert InvoiceTracker.lookup(invoice.number) == invoice
    end
  end

  describe "listing all invoices" do
    test "includes all recorded invoices" do
      invoice = make_invoice()
      paid = make_invoice(number: 46, paid_on: ~D{2017-04-06})
      InvoiceTracker.record(invoice)
      InvoiceTracker.record(paid)
      all = InvoiceTracker.all()

      assert(invoice in all)
      assert(paid in all)
    end
  end

  describe "listing unpaid invoices" do
    test "includes only unpaid invoices" do
      invoice = make_invoice()
      paid = make_invoice(number: 46, paid_on: ~D[2017-04-06])
      InvoiceTracker.record(invoice)
      InvoiceTracker.record(paid)
      unpaid = InvoiceTracker.unpaid()

      assert(invoice in unpaid)
      refute(paid in unpaid)
    end
  end

  describe "listing active invoices" do
    test "includes invoices recorded or paid since a given date" do
      paid_before = make_invoice(
        number: 42, date: ~D[2017-02-16], paid_on: ~D[2017-03-10]
      )
      paid_after = make_invoice(
        number: 43, date: ~D[2017-03-01], paid_on: ~D[2017-03-30]
      )
      unpaid = make_invoice(number: 44, date: ~D[2017-03-16])
      issued_after = make_invoice(number: 46, date: ~D[2017-04-01])
      InvoiceTracker.record(paid_before)
      InvoiceTracker.record(paid_after)
      InvoiceTracker.record(unpaid)
      InvoiceTracker.record(issued_after)
      active = InvoiceTracker.active_since(~D[2017-03-24])

      refute(paid_before in active)
      assert(paid_after in active)
      assert(unpaid in active)
      assert(issued_after in active)
    end
  end

  describe "oldest unpaid invoice" do
    test "returns unpaid invoice with the earliest date" do
      invoice = make_invoice(date: ~D{2017-01-16})
      earlier = make_invoice(number: 41, date: ~D[2017-01-01])
      earliest_but_paid = make_invoice(
        number: 40, date: ~D{2016-12-16}, paid_on: ~D{2017-01-18}
      )
      InvoiceTracker.record(invoice)
      InvoiceTracker.record(earliest_but_paid)
      InvoiceTracker.record(earlier)

      assert InvoiceTracker.oldest_unpaid_invoice() == earlier
    end
  end

  describe "next invoice number" do
    test "starts at 1" do
      assert InvoiceTracker.next_invoice_number() == 1
    end

    test "returns one more than previous highest number" do
      InvoiceTracker.record(make_invoice(number: 5))
      InvoiceTracker.record(make_invoice(number: 41))
      InvoiceTracker.record(make_invoice(number: 22))

      assert InvoiceTracker.next_invoice_number() == 42
    end
  end

  describe "recording a payment" do
    test "updates the invoice with the payment date" do
      invoice = make_invoice()
      InvoiceTracker.record(invoice)
      InvoiceTracker.pay(invoice.number, ~D{2017-02-08})
      updated = make_invoice(paid_on: ~D{2017-02-08})
      assert InvoiceTracker.lookup(invoice.number) == updated
    end
  end

  defp make_invoice(options \\ []) do
    %Invoice{
      number: options[:number] || 42,
      date: options[:date] || ~D{2017-01-16},
      amount: options[:amount] || 1250.34,
      paid_on: options[:paid_on]
    }
  end
end
