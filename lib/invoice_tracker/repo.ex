defprotocol InvoiceTracker.Repo do
  alias InvoiceTracker.Invoice

  @spec store(Invoice.t) :: :ok
  def store(_invoice)
end
