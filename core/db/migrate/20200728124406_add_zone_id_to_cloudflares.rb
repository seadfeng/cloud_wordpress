class AddZoneIdToCloudflares < ActiveRecord::Migration[6.0]
  def self.up
    add_column :wordpress_cloudflares, :zone_id, :string
  end
  def self.down
    remove_column :wordpress_cloudflares, :zone_id 
  end
end
