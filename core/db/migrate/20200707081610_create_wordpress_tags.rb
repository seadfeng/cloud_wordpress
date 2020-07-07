class CreateWordpressTags < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_tags do |t| 
      t.string :name, null: false,  default: '' 
      t.timestamps
    end
  end

  def down
    drop_table :wordpress_tags
  end
end
