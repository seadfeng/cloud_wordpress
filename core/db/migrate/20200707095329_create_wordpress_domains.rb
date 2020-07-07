class CreateWordpressDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :wordpress_domains do |t|
      t.string  :name , null: false, default: ''
      t.text    :description
      t.string  :state

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
