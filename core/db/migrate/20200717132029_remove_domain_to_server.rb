class RemoveDomainToServer < ActiveRecord::Migration[6.0]
  
  def up
    remove_column :wordpress_servers, :domain
  end

  def down
    add_column :wordpress_servers, :domain, :string,  null: false, default: "" 
  end 
  
end
