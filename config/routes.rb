Spree::Core::Engine.routes.draw do
  get "/samport/report" => "samport#report", :as => :samport_report
end
