class CreateWordpressPreferences < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_preferences do |t|
      t.string     :name, limit: 100
      t.references :owner, polymorphic: true
      t.text       :value
      t.string     :key
      t.string     :value_type 
      t.timestamps 
    end
    add_index :wordpress_preferences, [:key], name: 'index_wordpress_preferences_on_key', unique: true

  end

  def down
    drop_table :wordpress_preferences
  end
end
