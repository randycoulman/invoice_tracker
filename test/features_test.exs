defmodule FeaturesTest do
  @moduledoc false

  use ExUnit.Case, async: true

  setup_all do
    {_, 0} = System.cmd "mix", ["escript.build"]
    path = Briefly.create!(directory: true)
    file = Path.join(path, "invoices.ets")
    record_invoice(file, "99", "1298.45", "2017-02-16")
    record_invoice(file, "98", "1575.00", "2017-02-01")
    record_invoice(file, "100", "773.89", "2017-03-01")
    record_payment(file, "99", "2017-03-20")
    record_payment(file, "2017-03-06")
    {:ok, invoice_file: file}
  end

  describe "end to end" do
    test "shows active invoices in a table", %{invoice_file: file} do
      assert list_invoices(file) == """
      +------------+-----+--------+------+
      |    Date    |  #  | Amount | Paid |
      +------------+-----+--------+------+
      | 2017-03-01 | 100 | 773.89 |      |
      +------------+-----+--------+------+
      """
    end

    test "shows all recorded invoices in a table", %{invoice_file: file} do
      assert list_all_invoices(file) == """
      +------------+-----+----------+------------+
      |    Date    |  #  |  Amount  |    Paid    |
      +------------+-----+----------+------------+
      | 2017-02-01 |  98 | 1,575.00 | 2017-03-06 |
      | 2017-02-16 |  99 | 1,298.45 | 2017-03-20 |
      | 2017-03-01 | 100 |   773.89 |            |
      +------------+-----+----------+------------+
      """
    end
  end

  defp record_invoice(file, number, amount, date) do
    run("record", file, [number, amount, "--date", date])
  end

  defp record_payment(file, date) do
    run("payment", file, ["--date", date])
  end

  defp record_payment(file, number, date) do
    run("payment", file, ["--number", number, "--date", date])
  end

  defp list_invoices(file) do
    run("list", file)
  end

  defp list_all_invoices(file) do
    run("list", file, ["--all"])
  end

  defp run(command, file, args \\ []) do
    {output, 0} = System.cmd Path.expand("./invoice"),
      ["--file", file, command] ++ args
    output
  end
end
