class CreateWordpressTagsBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :wordpress_tags_blogs do |t|
      t.belongs_to :tag
      t.belongs_to :blog  
    end
  end
end
