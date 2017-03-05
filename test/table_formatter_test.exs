defmodule TableFormatterTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.{Invoice, TableFormatter}

  describe "with no invoices" do
    setup do
      {:ok, output: TableFormatter.format([])}
    end

    test "reports that there are no invoices", %{output: output} do
      assert output == "No invoices found\n"
    end
  end

  describe "with several invoices" do
    setup do
      invoices = [
        %Invoice{number: 30, date: ~D{2017-01-16}, amount: 1250.34},
        %Invoice{number: 100, date: ~D{2015-12-01}, amount: 15.00},
        %Invoice{number: 2, date: ~D{1999-07-16}, amount: 100_123.98}
      ]
      {:ok, output: TableFormatter.format(invoices)}
    end

    test "nicely formats the table", %{output: output} do
      assert output == """
      +------------+-----+------------+
      |    Date    |  #  |   Amount   |
      +------------+-----+------------+
      | 2017-01-16 |  30 |   1,250.34 |
      | 2015-12-01 | 100 |      15.00 |
      | 1999-07-16 |   2 | 100,123.98 |
      +------------+-----+------------+
      """
    end
  end
end
