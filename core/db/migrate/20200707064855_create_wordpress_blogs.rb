class CreateWordpressBlogs < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_blogs do |t|
      t.belongs_to :admin_user 
      t.belongs_to :servier 
      t.belongs_to :locale 
      t.belongs_to :cloudflare 
      t.belongs_to :domain 
       
      ## Site Info
      t.string 	   :cname,          default: "@" 
      t.string 	   :name 
      t.text       :description 
      t.string     :number   
      t.integer    :post ,                    null: false, default: 1  
      t.boolean    :use_ssl,                  null: false, default: 1 
      t.boolean    :dns_status,               null: false, default: 0
      t.string     :state
      t.string     :status
 

      ## Blog Administrator
      t.string 	   :user,                null: false, default: "admin" 
      t.string 	   :password,            null: false, default: "" 
 
      t.string    :mysql_user,                null: false, default: ""
      t.string    :mysql_password,              null: false, default: ""

      ##
      t.boolean  :installed,                  null: false, default: 0
      t.boolean  :published,                  null: false, default: 0
      
      t.datetime :installed_at
      t.datetime :published_at  
      t.datetime :deleted_at

      t.timestamps
    end 
    add_index :wordpress_blogs, [:number ], name: 'index_blogs_by_number', unique: true 

  end

  def down
    drop_table :wordpress_blogs
  end
end
