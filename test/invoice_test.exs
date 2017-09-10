defmodule InvoiceTest do
  @moduledoc false

  use ExUnit.Case

  import ShortMaps

  alias InvoiceTracker.Invoice

  setup do
    invoice = %Invoice{number: 42, amount: 1000.34, date: ~D[2017-01-01]}
    paid = Invoice.pay(invoice, ~D[2017-02-07])
    {:ok, invoice: invoice, paid: paid}
  end

  describe "paying an invoice" do
    test "marks the invoice as paid", ~m{paid}a do
      assert Invoice.paid?(paid)
    end

    test "records the payment date", ~m{paid}a do
      assert paid.paid_on == ~D[2017-02-07]
    end
  end

  describe "due date" do
    test "invoices are due 15 days after issue", ~m{invoice}a do
      assert Invoice.due_on(invoice) == ~D[2017-01-16]
    end
  end

  describe "has activity since a given date" do
    test "unpaid invoices have activity", ~m{invoice}a do
      assert Invoice.active_since?(invoice, ~D[2017-01-31])
    end

    test "issued invoices have activity", ~m{invoice}a do
      assert Invoice.active_since?(invoice, ~D[2016-12-20])
    end

    test "invoices paid before the date do not have activity", ~m{paid}a do
      refute Invoice.active_since?(paid, ~D[2017-02-13])
    end

    test "invoices paid on the date do not have activity", ~m{paid}a do
      refute Invoice.active_since?(paid, paid.paid_on)
    end

    test "invoices paid after the date have activity", ~m{paid}a do
      assert Invoice.active_since?(paid, ~D[2017-02-01])
    end
  end

  describe "status" do
    test "current if before due date", ~m{invoice}a do
      assert Invoice.status(invoice, ~D[2017-01-07]) == "Current"
    end

    test "current if on due date", ~m{invoice}a do
      assert Invoice.status(invoice, Invoice.due_on(invoice)) == "Current"
    end

    test "late if unpaid after due date", ~m{invoice}a do
      assert Invoice.status(invoice, ~D[2017-03-01]) == "44 days late"
    end

    test "paid on time if paid by due date", ~m{invoice}a do
      paid = Invoice.pay(invoice, ~D[2017-01-07])
      assert Invoice.status(paid, ~D[2017-01-31]) == "Paid on time"
    end

    test "paid on time if paid on due date", ~m{invoice}a do
      paid = Invoice.pay(invoice, Invoice.due_on(invoice))
      assert Invoice.status(paid, ~D[2017-01-31]) == "Paid on time"
    end

    test "late if paid after due date", ~m{paid}a do
      assert Invoice.status(paid, ~D[2017-03-01]) == "22 days late"
    end

    test "uses singular 'day' when one day late", ~m{invoice}a do
      assert Invoice.status(invoice, ~D[2017-01-17]) == "1 day late"
    end
  end
end
