Deface::Override.new(:virtual_path => "spree/shared/_footer",
                     :name => "samport_footer_logo",
                     :insert_bottom => "#footer-images .payments",
                     :text => "<%= image_tag 'credit_cards/icons/master.png', :class => 'mastercard' if Spree::PaymentMethod::Samport.active?  %><%= image_tag 'credit_cards/icons/visa.png', :class => 'visa' if Spree::PaymentMethod::Samport.active? %>")
  