class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, unique: true
      t.string :apply
      t.string :apply_one_month
      t.string :apply_manager
      t.string :password_digest
      t.string :remember_digest
      t.boolean :admin, default: false
      t.boolean :superior, default: false
      t.string :affiliation
      t.integer :employee_number
      t.integer :uid
      t.datetime :basic_work_time, default: Time.current.change(hour: 8, min: 0, sec: 0)
      t.datetime :designated_work_start_time, default: Time.current.change(hour: 10, min: 0, sec: 0)
      t.datetime :designated_work_end_time, default: Time.current.change(hour: 19, min: 0, sec: 0)

      t.timestamps
    end
  end
end
