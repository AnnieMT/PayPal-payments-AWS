require "braintree"

gateway = Braintree::Gateway.new(
  :environment => :sandbox,
  :merchant_id => "...",
  :public_key => "...",
  :private_key => "...",
)

client_token = gateway.client_token.generate(
  :customer_id => ""
)

puts client_token
