Spree::CheckoutController.class_eval do
  before_filter :redirect_to_samport_payment, :only => [:update]

  def redirect_to_samport_payment
    return unless params[:state] == "payment"
    logger.debug "\n----------- #{params} -----------\n"
    @payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    
    if @payment_method && @payment_method.kind_of?(Spree::PaymentMethod::Samport)
      @order.update_attributes(object_params)
      samport_key = Spree::SamportPayment.new.get_samport_key(@payment_method, @order)
      @order.payment.source.update_attribute(:samport_key, samport_key)
      redirect_uri = "https://secure.telluspay.com/WebOrder/?#{samport_key}"
      logger.debug "\n----------- Redirect to #{samport_key} -----------\n"
      redirect_to redirect_uri
    end
  end
end