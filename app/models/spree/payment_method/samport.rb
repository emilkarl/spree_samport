class Spree::PaymentMethod::Samport < Spree::PaymentMethod
  preference :terminal_id, :integer
  preference :transaction_type, :string, :default => '1'
  preference :direct_capture, :integer, :default => 0
  preference :iso_language_code, :string, :default => 'SE' 
  preference :iso_currency, :integer, :default => 752
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::SamportPayment
  end
end

