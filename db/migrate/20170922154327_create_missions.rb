class CreateMissions < ActiveRecord::Migration
  def change
    create_table :missions do |t|

      t.timestamps null: false
      t.string :company_id, null: false
      t.string :date
      t.string :name
      t.string :phone
      t.string :owners
      t.string :lat
      t.string :lon
    end
  end
end
