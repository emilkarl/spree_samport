class AddSamportCardType < ActiveRecord::Migration
  def change
    add_column :spree_samport_payments, :card_type, :string
  end
end