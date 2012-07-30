class Spree::PaymentMethod::Samport < Spree::PaymentMethod
  preference :terminal_id, :integer
  preference :transaction_type, :string, :default => '1'
  preference :direct_capture, :integer, :default => 0
  preference :iso_language_code, :string, :default => 'SE' 
  preference :iso_currency, :integer, :default => 752
  
  attr_accessible :terminal_id, :preferred_terminal_id, :transaction_type, :preferred_transaction_type, :direct_capture, :preferred_direct_capture, :iso_language_code, :preferred_iso_language_code, :iso_currency, :preferred_iso_currency
  
  def source_required?
    true
  end
  
  def payment_source_class
    Spree::SamportPayment
  end
end

