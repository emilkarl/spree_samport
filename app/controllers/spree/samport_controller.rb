class Spree::SamportController < Spree::BaseController
  def failure
    @order = current_user.orders.find_by_number(params[:order_number])
    
    unless @order && (@order.state == 'payment' || @order.state == 'complete') && @order.payment_method.is_a?(Spree::PaymentMethod::Samport)
      redirect_to checkout_state_path(@order.state) and return if @order.present?
      redirect_to root_path
    end
    
    #@order.payment.complete!
    @order.update_attribute(:state => 'payment')
    respond_with(@order, :location => checkout_state_path(@order.state))
  end
  
  def success
    @order = current_user.orders.find_by_number(params[:order_number])
    
    unless @order && (@order.state == 'payment' || @order.state == 'complete') && @order.payment_method.is_a?(Spree::PaymentMethod::Samport)
      redirect_to checkout_state_path(@order.state) and return if @order.present?
      redirect_to root_path
    end
    
    @order.payment.complete!
    @order.next
    
    redirect_to checkout_state_path(@order.state)
  end
end