class AddSamportClientIp < ActiveRecord::Migration
  def change
    add_column :spree_samport_payments, :client_ip, :string
  end
end