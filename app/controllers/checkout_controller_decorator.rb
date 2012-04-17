Spree::CheckoutController.class_eval do
  before_filter :redirect_to_samport_payment, :only => [:update]
  before_filter :update_flash_message, :only => [:edit]
  
  def redirect_to_samport_payment
    return unless params[:state] == "payment"
    logger.info "\n----------- Samport::CheckoutController.redirect_to_samport_payment #{params} -----------\n"
    @payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    
    if @payment_method && @payment_method.kind_of?(Spree::PaymentMethod::Samport)
     logger.debug "\n----------- #{object_params} -----------\n"
      @order.update_attributes(object_params)
      
      if @order.coupon_code.present?
        if Spree::Promotion.exists?(:code => @order.coupon_code)
          fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
          # If it doesn't exist, raise an error!
          # Giving them another chance to enter a valid coupon code
        else
          flash[:error] = t(:promotion_not_found)
          render :edit and return
        end
      end
      
      @order.update_attribute(:state, 'payment') # Set order state
      
      @order.payment.source.update_attribute(:client_ip, request.remote_ip) # Set client ip
     
      @order.payment.update_attribute(:state, 'pending') # Set payment state
      
      samport_key = Spree::SamportPayment.new.get_samport_key(@payment_method, @order)
      @order.payment.source.update_attribute(:samport_key, samport_key)
      
      redirect_uri = "https://secure.telluspay.com/WebOrder/?#{samport_key}" # create samport payment url
      redirect_to redirect_uri
    else
      return
    end
  end
  
  def update_flash_message
    logger.debug "\n----------- Samport::CheckoutController.update_flash_message -----------\n"
    flash[:error] = I18n.t(:samport_order_denied) if !params[:pstatus].blank? && params[:pstatus] == 'denied'
    return
  end
end