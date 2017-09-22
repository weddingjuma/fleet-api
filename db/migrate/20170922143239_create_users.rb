class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      t.timestamps null: false
      t.string :company_id, null: false
      t.string :user
      t.string :roles, array: true, default: []
    end
  end
end
