class AddUserIdToCloudflares < ActiveRecord::Migration[6.0]
  def self.up
    add_column :wordpress_cloudflares, :user_id, :string
  end
  def self.down
    remove_column :wordpress_cloudflares, :user_id 
  end
end
