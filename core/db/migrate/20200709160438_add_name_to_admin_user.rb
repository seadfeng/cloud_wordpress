class AddNameToAdminUser < ActiveRecord::Migration[6.0]
  def up
    add_column :admin_users, :first_name, :string 
    add_column :admin_users, :last_name, :string 
  end

  def down
    remove_column :admin_users, :first_name
    remove_column :admin_users, :last_name
  end
end
