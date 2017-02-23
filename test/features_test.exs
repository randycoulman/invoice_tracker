defmodule FeatureTest do
  @moduledoc false

  use ExUnit.Case, async: true

  setup_all do
    {_, 0} = System.cmd "mix", ["escript.build"]
    [file: Briefly.create!]
  end

  describe "recording an invoice" do
    setup %{file: file} do
      output = record_invoice(file, "42", "1298.45", "2017-02-16")
      [output: output]
    end

    test "it reports that the invoice was recorded", %{output: output} do
      assert output == "Recorded invoice #42 on 2017-02-16 for $1298.45\n"
    end
  end

  defp record_invoice(file, number, amount, date) do
    {output, 0} = System.cmd Path.expand("./invoice"),
      ["--file", file, "record", number, amount, "--date", date]
    output
  end
end
