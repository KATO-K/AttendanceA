require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社時間 退社時間)
  csv << column_names
  @attendances.each do |a|
    unless a.confirmation_one_month == "承認" 
      column_values = [
        a.worked_on
      ]
    else
      column_values = [
        a.worked_on,
        a.started_at, 
        a.finished_at
    ]
      
    end
    csv << column_values
  end
end