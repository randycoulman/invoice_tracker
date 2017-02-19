defmodule FeatureTest do
  @moduledoc false

  use ExUnit.Case, async: true

  setup_all do
    {_, 0} = System.cmd "mix", ["escript.build"]
    :ok
  end

  describe "recording an invoice" do
    setup do
      output = record_invoice("42", "1298.45", "2017-02-16")
      [output: output]
    end

    test "it reports that the invoice was recorded", %{output: output} do
      assert output == "Recorded invoice #42 on 2017-02-16 for $1298.45\n"
    end
  end

  defp record_invoice(number, amount, date) do
    IO.puts System.cwd
    {output, 0} = System.cmd Path.expand("./invoice"),
      ["record", number, amount, date]
    output
  end
end
