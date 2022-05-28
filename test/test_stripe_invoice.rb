require 'minitest/autorun'
require 'stripe'
require 'open-uri'

Stripe.api_key = ENV['API_KEY']

class StripeInvoiceGemTest < Minitest::Test
  def test_list_length
    list = Stripe::Invoice.list({limit: 1})
    assert_equal list.count, 1
  end

  #helper method to pass invoices into the hash in different scenarios
  def download_invoices(x, y)
    x.auto_paging_each do |invoice|
      if !invoice.invoice_pdf.nil?
        y[invoice.id] = invoice.invoice_pdf 
      end
    end
  end
  
  #this test ensures that the invoice count when you pull all invoices is equal to the invoice
  #count when you pull invoices after an index and invoices before an index, add them together + 1 for the index
  #as these two sums should be equal
  def test_case_one
    invoice_index = ENV['invoice_id']
    invoice_ids = Hash.new
    all_id = Hash.new
    all = Stripe::Invoice.list({limit: 100})
    starting_after = Stripe::Invoice.list({limit: 100,starting_after: invoice_index})
    ending_before = Stripe::Invoice.list({limit: 100, ending_before: invoice_index})
    download_invoices(all, all_id)
    download_invoices(starting_after,invoice_ids)
    download_invoices(ending_before,invoice_ids)
    assert_equal all_id.count,invoice_ids.count + 1
  end
end
