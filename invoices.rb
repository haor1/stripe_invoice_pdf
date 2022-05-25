#Ruby script to Download all your Stripe PDF invoices in bulk.

require 'stripe'
require 'open-uri'

puts 'Please note the process to download all of your invoice PDFs may take several minutes depending on the number of invoices in your account'
puts ""
puts 'Please enter your Stripe API key to retrieve your invoice PDFs in bulk: '
api_key = gets.chomp

Stripe.api_key = api_key

#creates the invoices directory if it does not exist. This is where the invoice PDFs will be downloaded
directory_name = "invoices"
Dir.mkdir(directory_name) unless File.exists?(directory_name)

#Stripe pagination to retrieve the full list of a User's invoices
invoice_ids = Hash.new
invoices = Stripe::Invoice.list({limit: 100})
invoices.auto_paging_each do |invoice|
  #This conditional statement ensures only invoices with a PDF are stored in our list
  if !invoice.invoice_pdf.nil?
    invoice_ids[invoice.id] = invoice.invoice_pdf 
  end
end

#prints the total number of a User's invoices which have an invoice PDF
puts "# of invoices: " + String(invoice_ids.length)

#This block copies the invoice PDF to the /invoices directory
invoice_ids.each do |k, v|
  open(v) do |image|
    File.open("./invoices/"+k+".pdf", "wb") do |file|
      file.write(image.read)
    end
  end  
end


