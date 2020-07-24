class AddDownloadUrlToBlogs < ActiveRecord::Migration[6.0]

  def up
    add_column :wordpress_blogs, :download_url, :string 
  end 
  
  def down
    remove_column :wordpress_blogs, :download_url
  end

end
