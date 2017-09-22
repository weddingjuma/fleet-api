class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.timestamps null: false
      t.string :name, null: false
      t.string :city
      t.string :country
      t.string :detail
      t.string :postalcode
      t.string :state
      t.string :street
    end
  end
end
