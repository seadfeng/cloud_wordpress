class AddDirectoryToProxy < ActiveRecord::Migration[6.0]
  def up
    add_column :wordpress_proxies, :directory, :string  
  end

  def down
    remove_column :wordpress_proxies, :directory
  end
end
