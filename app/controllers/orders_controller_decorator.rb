Spree::OrdersController.class_eval do
  before_filter :update_flash_message, :only => [:show]
  
  def update_flash_message
    # Payment successful
    if !params[:pstatus].blank? && params[:pstatus] = "successful"
      session[:order_id] = nil
      flash[:notice] = t(:order_processed_successfully)
    end
    return
  end
end