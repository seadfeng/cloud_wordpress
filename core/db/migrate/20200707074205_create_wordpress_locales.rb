class CreateWordpressLocales < ActiveRecord::Migration[6.0]

  def up
    create_table :wordpress_locales do |t| 
      t.string  :name, 		 null: false, default: ""
      t.string  :code, 		 null: false, default: ""
      t.integer :position,	 null: false, default: 0 
      t.timestamps
      t.index ["code"], name: "index_locales_on_code", unique: true
      t.index ["name"], name: "index_locales_on_name", unique: true 
    end
  end

  def down
    drop_table :wordpress_locales
  end

end
