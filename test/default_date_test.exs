defmodule DefaultDateTest do
  @moduledoc false

  use ExUnit.Case
  alias InvoiceTracker.DefaultDate

  describe "default invoice date" do
    test "uses today if that's the invoice date" do
      assert DefaultDate.for_invoice(~D[2017-03-16]) == ~D[2017-03-16]
      assert DefaultDate.for_invoice(~D[2017-03-01]) == ~D[2017-03-01]
    end

    test "uses most recently past invoice date" do
      assert DefaultDate.for_invoice(~D[2017-03-02]) == ~D[2017-03-01]
      assert DefaultDate.for_invoice(~D[2017-03-14]) == ~D[2017-03-01]
    end

    test "uses tomorrow if that's the invoice date" do
      assert DefaultDate.for_invoice(~D[2017-03-15]) == ~D[2017-03-16]
      assert DefaultDate.for_invoice(~D[2017-02-28]) == ~D[2017-03-01]
    end

    test "only goes one day into the future" do
      assert DefaultDate.for_invoice(~D[2017-03-30]) == ~D[2017-03-16]
    end

    test "works for leap years" do
      assert DefaultDate.for_invoice(~D[2016-02-28]) == ~D[2016-02-16]
      assert DefaultDate.for_invoice(~D[2016-02-29]) == ~D[2016-03-01]
    end

    test "works at year-end boundary" do
      assert DefaultDate.for_invoice(~D[2016-12-30]) == ~D[2016-12-16]
      assert DefaultDate.for_invoice(~D[2016-12-31]) == ~D[2017-01-01]
    end
  end

  describe "default payment date" do
    test "always uses today" do
      assert DefaultDate.for_payment(~D[2017-03-07]) == ~D[2017-03-07]
    end
  end

  describe "default current status date" do
    test "uses today if it's Friday" do
      assert DefaultDate.for_current_status(~D[2017-03-10]) == ~D[2017-03-10]
    end

    test "uses most recent Friday" do
      assert DefaultDate.for_current_status(~D[2017-03-09]) == ~D[2017-03-03]
    end
  end

  describe "default previous status date" do
    test "always one week ago" do
      assert DefaultDate.for_previous_status(~D[2017-03-07]) == ~D[2017-02-28]
    end
  end
end
