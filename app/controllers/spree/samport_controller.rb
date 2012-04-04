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
    
    raise Spree::Core::GatewayError.new('No access') unless samport_servers.include? request.remote_ip
    
    order = Spree::Order.find_by_number(params[:order_number])
    
    if params[:response_code] == '00'
      success(order)
    else
      failure(order)
    end
    
    render :nothing => true
  end
  
  private
  def failure(order)
    logger.debug "\n--------- Samport.report.failure >> #{order.number} >> #{order.id} >> #{order.state} ---------"
    order.update_attribute(:state, 'payment')
    logger.debug "\n--------- #{I18n.t(:samport_payment_process_failed)} ---------"
  end
  
  def success(order)
    logger.debug "\n--------- Samport.report.success >> #{order.number} >> #{order.id} >> #{order.state} ---------"
    order.next
    order.payment.complete!
    logger.debug "\n--------- #{I18n.t(:order_processed_successfully)} ---------"
  end
end