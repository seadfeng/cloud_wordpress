class AddDomainToCloudflare < ActiveRecord::Migration[6.0]
  def self.up
    add_column :wordpress_cloudflares, :domain, :string
  end
  def self.down
    remove_column :wordpress_cloudflares, :domain 
  end
end
