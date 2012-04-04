Spree::OrdersController.class_eval do
  before_filter :update_flash_message, :only => [:show]
  
  def update_flash_message
    logger.debug "\n----------- Samport::OrdersController.update_flash_message -----------\n"
    flash[:notice] = t(:order_processed_successfully) if !params[:pstatus].blank? && params[:pstatus] = "successful"
  end
end