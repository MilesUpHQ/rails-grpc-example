class AddGuestIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :guest_id, :text
  end
end
