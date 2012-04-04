class Spree::SamportPayment < ActiveRecord::Base
  has_many :payments, :as => :source
  
  attr_accessible :samport_key
  
  def actions
    %w{}
  end

  def process!(payment)
    logger.debug "\n----------- SamportPayment.process! -----------\n"
  end
  
  def get_samport_key(payment_method, order)
    logger.debug "\n----------- SamportPayment.get_samport_key -----------\n"
    terminal_id = payment_method.preferred(:terminal_id)
    direct_capture = payment_method.preferred(:direct_capture)
    transaction_type = payment_method.preferred(:transaction_type)
    iso_language_code = payment_method.preferred(:iso_language_code)
    iso_currency = payment_method.preferred(:iso_currency)
    @request_input = {}
    data = []
    
    # Add products
    order.line_items.each do |item|
      logger.debug "\n----------- Item: #{item.quantity}, #{item.product.sku}, #{item.product.name}, #{item.product.price} -----------\n"
      # <ArtNo>:<Description>:<Quantity>:<Price in the lowest value (ören, cent etc.)>
      price = item.product.price * 100
      data << "#{item.product.sku}:#{item.product.name}:#{item.quantity}:#{price.to_i}"
    end
    
    # Shipping cost
    shipping_cost = order.ship_total * 100 * 1.25; # Swedish VAT at 25%
    
    data << "1:#{order.shipping_method.name}:1:#{shipping_cost.to_i}"

    data = data.join(',')
    extra_data= "#order_number=#{order.number}#order_id=#{order.id}#payment_id=#{order.payment.id}"
    
    @domain = "http://unix.telluspay.com/Add/?"
    @querystring = "TP01=#{direct_capture}&TP700=#{terminal_id}&TP701=#{order.number}&TP740=#{URI.escape(data)}&TP901=#{transaction_type}&TP491=#{iso_language_code}&TP490=#{iso_currency}&TP801=#{URI.escape(order.email)}&TP8021=#{URI.escape(order.bill_address.firstname)}&TP8022=#{URI.escape(order.bill_address.lastname)}&TP803=#{URI.escape(order.bill_address.address1)}&TP804=#{URI.escape(order.bill_address.zipcode)}&TP805=#{URI.escape(order.bill_address.city)}&TP806=#{order.bill_address.country.iso}&TP8071=#{order.user.id}&TP900=127.0.0.1&TP950=#{URI.escape(extra_data)}"
    logger.debug "\n----------- SamportPayment.create url -----------\n"
    logger.debug "\n----------- #{@domain}#{@querystring} -----------\n"
    
    require 'uri'
    require 'open-uri'
    response = open("#{@domain}#{@querystring}").read
    logger.debug "\n----------- #{response} -----------\n"
    response
  end
  
  private
  def gateway_error(text)
    msg = "#{I18n.t(:gateway_error)} ... #{text}"
    logger.error(msg)
    raise Spree::Core::GatewayError.new(msg)
  end
end
