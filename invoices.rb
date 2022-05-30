#Ruby script to Download all your Stripe PDF invoices in bulk.

require 'stripe'
require 'open-uri'

puts 'Please note the process to download all of your invoice PDFs may take several minutes depending on the number of invoices in your account'
puts ""
puts 'Please enter your Stripe API key to retrieve your invoice PDFs in bulk: '
Stripe.api_key = gets.chomp

#Ask for user input to determine whether to download all invoices or only invoices before or after a certain invoice
puts ""
puts 'Please enter 1 if you would like to download all of your invoices. Please enter 2 if you would like to download invoices created after a given invoice.
Please enter 3 if you would like to download invoices created before a given invoice.'
puts ""
option = nil
until option == 3 || option == 2 || option == 1
  option = gets.chomp.to_i
end

if option == 2
  puts 'Please enter an invoice ID (in_xxx). Only invoices created after this invoice will be downloaded.'
  starting_after = gets.chomp
elsif option == 3
  puts 'Please enter an invoice ID (in_xxx). Only invoices created before this invoice will be downloaded.'
  ending_before = gets.chomp
end

#creates the invoices directory if it does not exist. This is where the invoice PDFs will be downloaded
directory_name = "invoices"
Dir.mkdir(directory_name) unless File.exists?(directory_name)

puts "Please wait..."

case option
#option to dowload all invoices
when 1
  invoices = Stripe::Invoice.list({limit: 100})
#option to download all invoices after a given invoice
when 2
  invoices = Stripe::Invoice.list({limit: 100, starting_after: starting_after})
#option to download all invoices before a given invoice
when 3
  invoices = Stripe::Invoice.list({limit: 100, ending_before: ending_before})
end

#Stripe pagination to retrieve the full list of a User's invoices
invoice_ids = Hash.new
invoices.auto_paging_each do |invoice|
  #This conditional statement ensures only invoices with a PDF are stored in our list
  if !invoice.invoice_pdf.nil?
    invoice_ids[invoice.id] = invoice.invoice_pdf 
  end
end

#prints the total number of a User's invoices which have an invoice PDF
puts "Now downloading the following number of invoices:  " + String(invoice_ids.length)

#This block copies each of the invoice PDFs to the /invoices directory
invoice_ids.each do |k, v|
  open(v) do |image|
    File.open("./invoices/"+k+".pdf", "wb") do |file|
      file.write(image.read)
    end
  end  
end


