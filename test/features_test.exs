defmodule FeaturesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import ShorterMaps

  @moduletag :features

  setup_all do
    {_, 0} = System.cmd("mix", ["escript.build"])
    path = Briefly.create!(directory: true)
    file = Path.join(path, "invoices.ets")
    record_invoice(file, "99", "1298.45", "2017-02-16")
    record_invoice(file, "98", "1575.00", "2017-02-01")
    record_invoice(file, "773.89", "2017-03-01")
    record_invoice(file, "1322.28", "2017-03-16")
    record_payment(file, "99", "2017-03-20")
    record_payment(file, "2017-02-15")
    {:ok, invoice_file: file}
  end

  describe "end to end" do
    test "shows active invoices in a table", ~M{invoice_file} do
      assert list_invoices(invoice_file) == """
             +------------+-----+----------+------+
             |    Date    |  #  |  Amount  | Paid |
             +------------+-----+----------+------+
             | 2017-03-01 | 100 |   773.89 |      |
             | 2017-03-16 | 101 | 1,322.28 |      |
             +------------+-----+----------+------+
             """
    end

    test "shows all recorded invoices in a table", ~M{invoice_file} do
      assert list_all_invoices(invoice_file) == """
             +------------+-----+----------+------------+
             |    Date    |  #  |  Amount  |    Paid    |
             +------------+-----+----------+------------+
             | 2017-02-01 |  98 | 1,575.00 | 2017-02-15 |
             | 2017-02-16 |  99 | 1,298.45 | 2017-03-20 |
             | 2017-03-01 | 100 |   773.89 |            |
             | 2017-03-16 | 101 | 1,322.28 |            |
             +------------+-----+----------+------------+
             """
    end

    test "reports invoice status as of a date", ~M{invoice_file} do
      assert invoice_status(invoice_file, "2017-03-31", "2017-03-17") === """
             +----------------------------------------------------------------------+
             |                   Invoice status as of 2017-03-31                    |
             +------------+-----+----------+------------+------------+--------------+
             |    Date    |  #  |  Amount  |    Due     |    Paid    |    Status    |
             +------------+-----+----------+------------+------------+--------------+
             | 2017-02-16 |  99 | 1,298.45 | 2017-03-03 | 2017-03-20 | 17 days late |
             | 2017-03-01 | 100 |   773.89 | 2017-03-16 |            | 15 days late |
             | 2017-03-16 | 101 | 1,322.28 | 2017-03-31 |            | Current      |
             +------------+-----+----------+------------+------------+--------------+
             """
    end
  end

  defp record_invoice(file, amount, date) do
    run("record", file, [amount, "--date", date])
  end

  defp record_invoice(file, number, amount, date) do
    run("rec", file, [amount, "--date", date, "--number", number])
  end

  defp record_payment(file, date) do
    run("payment", file, ["--date", date])
  end

  defp record_payment(file, number, date) do
    run("pay", file, ["--number", number, "--date", date])
  end

  defp list_invoices(file) do
    run("list", file)
  end

  defp list_all_invoices(file) do
    run("ls", file, ["--all"])
  end

  defp invoice_status(file, status_date, previous_date) do
    run("status", file, ["--date", status_date, "--since", previous_date])
  end

  defp run(command, file, args \\ []) do
    {output, 0} = System.cmd(Path.expand("./invoice"), ["--file", file, command] ++ args)
    output
  end
end
