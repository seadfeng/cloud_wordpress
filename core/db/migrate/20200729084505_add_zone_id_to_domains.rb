class AddZoneIdToDomains < ActiveRecord::Migration[6.0]
  def self.up
    add_column :wordpress_domains, :zone_id, :string
  end
  def self.down
    remove_column :wordpress_domains, :zone_id 
  end
end
