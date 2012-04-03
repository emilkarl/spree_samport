class CreateSamportPayments < ActiveRecord::Migration
  def change
    create_table :spree_samport_payments, :force => true do |t|
      t.string   :samport_key
      t.timestamps
    end
  end
end
