class CreateWordpressCloudflares < ActiveRecord::Migration[6.0]
  def up
    create_table :wordpress_cloudflares do |t|
      t.string :name, default: '', null: false
      t.text   :description 
      t.string :api_token, default: '', null: false
      t.string :api_user, default: '', null: false
      t.integer  :max_size, default: 3500, null: false
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def down
    drop_table :wordpress_cloudflares
  end
end
