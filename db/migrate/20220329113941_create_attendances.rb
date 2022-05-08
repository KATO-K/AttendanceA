class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :before_started_at
      t.datetime :before_finished_at
      t.datetime :apply_time
      t.string :note
      t.datetime :scheduled_end_time
      t.string :next_day
      t.string :business_process
      t.string :confirmation, default: "なし"
      t.string :confirmation_one_month, default: "なし"
      t.string :confirmation_manager, default: "なし"
      t.string :confirmation_user, default: "なし"
      t.string :change
      t.string :change_manager
      t.string :change_one_month
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
