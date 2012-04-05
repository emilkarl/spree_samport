class Spree::SamportController < Spree::BaseController
  
  def report
    logger.debug "\n--------- Samport.report >> #{params} for client #{request.remote_ip} ---------"
    
    samport_servers = [
      '82.99.3.1',
      '82.99.3.32',
      '88.80.180.132',
      '88.80.180.142',
      'https://secure.telluspay.com',
      '127.0.0.1'
      ]
    
    # Deny access for clients that are not Samport or localhost (for testing)
    raise Spree::Core::GatewayError.new('No access') unless samport_servers.include? request.remote_ip
    
    order = Spree::Order.find_by_number(params[:order_number])
    
    if params[:response_code] == '00' # Response Code OK, approved payment
      success(order)
    else # Denied payment
      failure(order)
    end
    
    render :nothing => true
  end
  
  private
  def failure(order)
    logger.debug "\n--------- Samport.report.failure >> #{order.number} >> #{order.id} >> #{order.state} ---------"
    order.update_attribute(:state, 'payment')
    order.payment.update_attribute(:state, 'denied')
    logger.debug "\n--------- #{I18n.t(:samport_payment_process_failed)} ---------"
  end
  
  def success(order)
    logger.debug "\n--------- Samport.report.success >> #{order.number} >> #{order.id} >> #{order.state} ---------"
    order.payment.complete!
    order.next
    logger.debug "\n--------- #{I18n.t(:order_processed_successfully)} ---------"
  end
end