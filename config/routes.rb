Spree::Core::Engine.routes.draw do
  get "/samport/success" => "samport#success", :as => :samport_success 
  get "/samport/failure" => "samport#failure", :as => :samport_failure
end
