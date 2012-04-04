class Spree::SamportController < Spree::BaseController
  
  respond_to :html
  
  def failure
    @order = current_user.orders.find_by_number(params[:order_number])
    logger.debug "\n--------- #{params[:order_number]} >> #{@order.id} >> #{@order.state} ---------"
    unless @order && (@order.state == 'payment' || @order.state == 'complete') && @order.payment_method.is_a?(Spree::PaymentMethod::Samport)
      redirect_to checkout_state_path(@order.state) and return if @order.present?
      redirect_to root_path
    end
    current_order = @order
    @order.update_attribute(:state, 'payment')
    flash[:error] = I18n.t(:samport_payment_process_failed)
    redirect_to checkout_state_path(@order.state)
  end
  
  def success
    @order = current_user.orders.find_by_number(params[:order_number])
    logger.debug "\n--------- #{params[:order_number]} >> #{@order.id} >> #{@order.state} ---------"
    unless @order && (@order.state == 'payment' || @order.state == 'complete') && @order.payment_method.is_a?(Spree::PaymentMethod::Samport)
      logger.debug "\n--------- SamportController -> Redirect to state or root ---------"
      redirect_to checkout_state_path(@order.state) and return if @order.present?
      redirect_to root_path
    end
    logger.debug "\n--------- #{@order.id} ---------"
    current_order = @order
    @order.next
    @order.payment.complete!
    flash[:notice] = t(:order_processed_successfully)
    flash[:commerce_tracking] = "nothing special"
    redirect_to order_path @order
  end
end