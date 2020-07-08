class CreateWordpressTemplates < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_templates do |t|
      t.belongs_to :locale
      t.string 	   :install_url,           null: false, default: ""
      t.string 	   :name,                  null: false, default: ""
      t.string 	   :description
      
      t.string 	   :wordpress_user,        null: false, default: "admin"
      t.string 	   :wordpress_password,      null: false, default: ""
 
      t.string 	   :mysql_user,            null: false, default: ""
      t.string     :mysql_password,        null: false, default: ""

      t.boolean    :installed,             null: false, default: 0

      t.datetime :deleted_at
      t.timestamps
    end
  end
  def down
    drop_table :wordpress_templates
  end
end
