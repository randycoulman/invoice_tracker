defmodule InvoiceReporterTest do
  @moduledoc false

  use ExUnit.Case

  import ShorterMaps

  alias InvoiceTracker.{Invoice, InvoiceReporter}

  describe "with no invoices" do
    setup do
      {:ok, invoices: []}
    end

    test "reports that the list is empty", ~M{invoices} do
      output = InvoiceReporter.format_list(invoices)
      assert output == "No invoices found\n"
    end

    test "reports that the status report is empty", ~M{invoices} do
      output = InvoiceReporter.format_status(invoices, ~D[2017-03-30])
      assert output == "No active invoices\n"
    end
  end

  describe "with several invoices" do
    setup do
      invoices = [
        %Invoice{
          number: 30,
          date: ~D{2017-01-16},
          amount: 1250.34,
          paid_on: ~D{2017-01-28}
        },
        %Invoice{number: 100, date: ~D{2015-12-01}, amount: 15.00},
        %Invoice{number: 2, date: ~D{1999-07-16}, amount: 100_123.98}
      ]
      {:ok, invoices: invoices}
    end

    test "nicely formats the list", ~M{invoices} do
      output = InvoiceReporter.format_list(invoices)
      assert output == """
      +------------+-----+------------+------------+
      |    Date    |  #  |   Amount   |    Paid    |
      +------------+-----+------------+------------+
      | 2017-01-16 |  30 |   1,250.34 | 2017-01-28 |
      | 2015-12-01 | 100 |      15.00 |            |
      | 1999-07-16 |   2 | 100,123.98 |            |
      +------------+-----+------------+------------+
      """
    end

    test "nicely formats the status report", ~M{invoices} do
      output = InvoiceReporter.format_status(invoices, ~D[2017-01-15])
      assert output == """
      +--------------------------------------------------------------------------+
      |                     Invoice status as of 2017-01-15                      |
      +------------+-----+------------+------------+------------+----------------+
      |    Date    |  #  |   Amount   |    Due     |    Paid    |     Status     |
      +------------+-----+------------+------------+------------+----------------+
      | 2017-01-16 |  30 |   1,250.34 | 2017-01-31 | 2017-01-28 | Paid on time   |
      | 2015-12-01 | 100 |      15.00 | 2015-12-16 |            | 396 days late  |
      | 1999-07-16 |   2 | 100,123.98 | 1999-07-31 |            | 6378 days late |
      +------------+-----+------------+------------+------------+----------------+
      """
    end
  end
end
