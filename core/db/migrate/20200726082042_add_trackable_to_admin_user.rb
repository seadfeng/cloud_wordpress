class AddTrackableToAdminUser < ActiveRecord::Migration[6.0]
  def up
    add_column :admin_users,  :sign_in_count, :integer , default: 0, null: false 
    add_column :admin_users,  :current_sign_in_at,  :datetime 
    add_column :admin_users,  :last_sign_in_at,  :datetime 
    add_column :admin_users,  :current_sign_in_ip,  :string 
    add_column :admin_users,  :last_sign_in_ip,  :string 
  end 
  
  def down
    remove_column :admin_users, :sign_in_count
    remove_column :admin_users, :current_sign_in_at
    remove_column :admin_users, :last_sign_in_at 
    remove_column :admin_users, :current_sign_in_ip
    remove_column :admin_users, :last_sign_in_ip
  end
end
