class AddTimeZoneToAdminUser < ActiveRecord::Migration[6.0]
  def self.up
    add_column :admin_users, :time_zone, :string
  end
  def self.down
    remove_column :admin_users, :time_zone 
  end
end
