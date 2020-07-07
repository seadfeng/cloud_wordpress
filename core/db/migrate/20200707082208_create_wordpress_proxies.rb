class CreateWordpressProxies < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_proxies do |t|
      t.string  :name
      t.string  :host,                     null: false, default: ""
      t.string  :connection_type,          null: false, default: ""
      t.integer :port,                     null: false, default: 22
   	  t.string  :user,                     null: false, default: ""
   	  t.string  :password,                 null: false, default: "" 
      t.text    :description   
      t.boolean :status,                  default: 0

      t.datetime :deleted_at
      t.datetime :uploaded_at
      t.datetime :installed_at

      t.timestamps  
      t.index ["host","user"], name: "index_php_proxies_on_host_and_user", unique: true
    end
  end

  def down
    drop_table :wordpress_proxies
  end

end
