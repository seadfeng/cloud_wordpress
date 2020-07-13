class CreateWordpressServers < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_servers do |t|
      t.belongs_to :cloudflare 
      t.integer  :max_size,  null: false, default: 200 
      t.string   :name
      t.text     :description
      t.datetime :deleted_at

      ## Domain
      t.string  :domain,                     null: false, default: "" 

      ## Host
      t.string  :host,                     null: false, default: ""
      t.integer :host_port,                null: false, default: 22
   	  t.string  :host_user,                null: false, default: ""
   	  t.string  :host_password,              null: false, default: "" 
      t.boolean :host_status,              null: false, default: 0 
      t.boolean :dns_status,               null: false, default: 0 
      t.boolean :installed,                null: false, default: 0

      ## Mysql
      t.string  :mysql_host,                null: false, default: ""
      t.string  :mysql_host_user,           null: false, default: ""
      t.integer :mysql_port,                null: false, default: 3306
   	  t.string  :mysql_user,                null: false, default: ""
   	  t.string  :mysql_password,              null: false, default: ""  
   	  t.boolean :mysql_status    

      t.timestamps 
      t.index ["host"], name: "index_servers_on_host", unique: true

    end
  end

  def down
    drop_table :wordpress_servers
  end

end
