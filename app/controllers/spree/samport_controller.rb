class Spree::SamportController < Spree::BaseController
  
  def report
    logger.info "\n--------- Samport.report >> #{params} for client #{request.remote_ip} ---------"
    
    samport_servers = [
      '82.99.3.1',
      '82.99.3.32',
      '82.99.3.20',
      '88.80.180.132',
      '88.80.180.142',
      'https://secure.telluspay.com',
      '127.0.0.1'
      ]
    
    # Deny access for clients that are not Samport or localhost (for testing)
    # TODO : This should render a 403 page instead of raising exception
    raise Spree::Core::GatewayError.new('Access Denied') unless samport_servers.include? request.remote_ip
    
    order = Spree::Order.find_by_number(params[:order_number])
    
    if params[:response_code].to_s == '00' # Response Code OK, approved payment
      success(order, params[:card_type].blank? ? nil : params[:card_type])
    else # Denied payment
      failure(order)
    end
    
    render :nothing => true
  end
  
  private
  def failure(order)
    logger.info "\n--------- Samport.report.failure >> #{order.number} >> #{order.id} >> #{order.state} ---------"
    order.update_attribute(:state, 'payment')
    order.payment.update_attribute(:state, 'failed')
    logger.info "\n--------- #{I18n.t(:samport_payment_process_failed)} ---------"
  end
  
  def success(order, card_type = nil)
    logger.info "\n--------- Samport.report.success >> #{order.number} >> #{order.id} >> #{order.state} ---------"
    order.payment.source.update_attribute(:card_type, card_type) unless card_type.blank?
    order.payment.update_attribute(:state, 'completed')
    order.update!
    order.next
    logger.info "\n--------- #{I18n.t(:order_processed_successfully)} ---------"
  end
end