defmodule InvoiceTrackerTest do
  @moduledoc false

  use ExUnit.Case
  import Mock
  alias InvoiceTracker.Invoice
  alias InvoiceTracker.Repo

  # doctest InvoiceTracker

  describe "recording an invoice" do
    test_with_mock "it remembers the invoice", Repo,
      [store: fn(_invoice) -> :ok end] do
      invoice = %Invoice{number: 42, date: ~D{2017-01-16}, amount: 1250.34}
      InvoiceTracker.record(Repo, invoice)
      assert called Repo.store(invoice)
    end
  end
end
