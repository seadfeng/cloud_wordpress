class CreateWordpressBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :wordpress_blogs do |t|

      t.timestamps
    end
  end
end
