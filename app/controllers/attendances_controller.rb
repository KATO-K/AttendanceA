class AttendancesController < ApplicationController
 
  
  before_action :set_user, only: [:edit_one_month, :update_one_month,
                                  :edit_overtime, :update_overtime,
                                  :edit_manager, :update_manager,
                                  :edit_apply_overtime, :update_apply_overtime,
                                  :edit_apply_one_month, :update_apply_one_month,
                                  :edit_apply_manager, :update_apply_manager,
                                  :log_attendances]
  before_action :logged_in_user, only: [:update,
                                        :edit_one_month, 
                                        :edit_overtime, 
                                        :edit_manager,
                                        :edit_apply_overtime,
                                        :edit_apply_one_month,
                                        :edit_apply_manager,
                                        :log_attendances]
  before_action :superior_or_correct_user, only: [:update, 
                                                  :edit_one_month, :update_one_month, 
                                                  :edit_overtime, :update_overtime, 
                                                  :edit_manager, :update_manager,
                                                  :edit_apply_overtime, :update_apply_overtime,
                                                  :edit_apply_one_month, :update_apply_one_month,
                                                  :edit_apply_manager, :update_apply_manager,
                                                  :log_attendances]
  before_action :superior_user, only: [:edit_apply_overtime, :update_apply_overtime,
                                      :edit_apply_one_month, :update_apply_one_month,
                                      :edit_apply_manager, :update_apply_manager,
                                      :log_attendances]
  before_action :set_one_month, only: [:edit_one_month,
                                       :edit_manager, 
                                       :edit_apply_overtime,
                                       :edit_apply_one_month,
                                       :edit_apply_manager,
                                       :log_attendances]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update(started_at: Time.current.change(sec: 0), 
                            before_started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update(finished_at: Time.current.change(sec: 0),
                            before_finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "勤怠データ.csv", type: :csv
      end
    end
  end

  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        unless item[:confirmation_one_month] == "なし"
          attendance.update!(item)
          unless attendance.before_started_at.present?
          attendance.update(before_started_at: attendance.started_at)
          end
          unless attendance.before_finished_at.present?
          attendance.update(before_finished_at: attendance.finished_at)
          end
          if attendance.confirmation_one_month == "上長A" || attendance.confirmation_one_month == "上長B"
          attendance.update(confirmation_user: attendance.confirmation_one_month)
          @user.update(apply_one_month: "申請中")
          end
        end
        flash[:warning] = "指示者確認の指定がない日付の更新はされませんでした。"
      end
    end
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_overtime
    @attendances = @user.attendances.where(id: params[:format])
  end

  def update_overtime
    ActiveRecord::Base.transaction do # トランザクションを開始します。
    @attendance = Attendance.find(params[:format])
    @user = User.find(@attendance.user_id)
    @attendance.update(overtime_params)
      if @attendance.confirmation == "上長A" || @attendance.confirmation == "上長B"
         @user.update(apply: "申請中")
      end
    end
    flash[:warning] = "就業していない日の残業申請は無効化されます。"
    flash[:info] = "残業申請を送信しました。"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。  
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_overtime_user_url(date: params[:date])
  end

  def edit_apply_overtime
    @users = User.where(apply: "申請中")
  end

  def update_apply_overtime
    ActiveRecord::Base.transaction do # トランザクションを開始します。     
      apply_overtime_params.each do |id, item| 
      attendance = Attendance.find(id)
      user = User.find(attendance.user_id)
        unless (item[:change] == "0" && item[:confirmation] == "承認") ||
               (item[:change] == "0" && item[:confirmation] == "否認") ||
               (item[:change] == "1" && item[:confirmation] == "なし") ||
               (item[:change] == "0" && item[:confirmation] == "なし")
              attendance.update!(item)            
              user.update(apply: "0") 
        else
          flash[:warning] = "変更にチェックがない項目は更新されませんでした。"
        end
      end
      @apply = User.where(apply: "0")
      @apply.each do |user|
        user.attendances.each do |attendance|
          if attendance.confirmation == "上長A" || attendance.confirmation == "上長B"
             user.update(apply: "申請中")
          end
        end
      end
    end
    
    flash[:success] = "残業申請を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_apply_overtime_user_url(date: params[:date])
  end
  
  def edit_apply_one_month
    @users = User.where(apply_one_month: "申請中")
  end

  def update_apply_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      apply_one_month_params.each do |id, item|
        attendance = Attendance.find(id)
        user = User.find(attendance.user_id)
        unless (item[:confirmation_one_month] == "承認" && item[:change_one_month] == "0") ||
               (item[:confirmation_one_month] == "否認" && item[:change_one_month] == "0") ||
               (item[:confirmation_one_month] == "なし" && item[:change_one_month] == "1") ||
               (item[:confirmation_one_month] == "なし" && item[:change_one_month] == "0")
              attendance.update!(item)
              attendance.update(apply_time:Time.now)            
              user.update(apply_one_month: "0")   
        end
        flash[:warning] = "変更にチェックがない項目は更新されませんでした。"
      end
      @apply = User.where(apply_one_month: "0")
      @apply.each do |user|
        user.attendances.each do |attendance|
          if attendance.confirmation_one_month == "上長A" || attendance.confirmation_one_month == "上長B"
             user.update(apply_one_month: "申請中")
          end
        end
      end
    end
    flash[:success] = "勤怠変更申請を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_apply_one_month_user_url(date: params[:date])
  end
  

  def edit_manager
  end

  def update_manager
    ActiveRecord::Base.transaction do # トランザクションを開始します。
    attendance = Attendance.find_by(worked_on: params[:date], user_id: params[:id])
    attendance.update!(manager_params)
    if attendance.confirmation_manager == "上長A" || attendance.confirmation_manager == "上長B"
      @user.update(apply_manager: "申請中")
    end
    flash[:success] = "1ヶ月分の勤怠情報を申請しました。"
    redirect_to user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to user_url(date: params[:date])
  end

  def edit_apply_manager
    @users = User.where(apply_manager: "申請中")
  end

  def update_apply_manager
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      apply_manager_params.each do |id, item|
        attendance = Attendance.find(id)
        user = User.find(attendance.user_id)
        unless (item[:confirmation_manager] == "承認" && item[:change_manager] == "0") ||
               (item[:confirmation_manager] == "否認" && item[:change_manager] == "0") ||
               (item[:confirmation_manager] == "なし" && item[:change_manager] == "1") ||
               (item[:confirmation_manager] == "なし" && item[:change_manager] == "0")
              attendance.update!(item)            
              user.update(apply_manager: "0")   
        end
        flash[:warning] = "変更にチェックがない項目は更新されませんでした。"
      end
      @apply = User.where(apply_manager: "0")
      @apply.each do |user|
        user.attendances.each do |attendance|
          if attendance.confirmation_manager == "上長A" || attendance.confirmation_manager == "上長B"
             user.update(apply_manager: "申請中")
          end
        end
      end
    end
    flash[:success] = "所属長承認申請を更新しました。"
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_apply_manager_user_url(date: params[:date])
  end

  def log_attendances
    years = {}
    months = {}
    @attendances = Attendance.where(confirmation_one_month: "承認")

    if params[:year].present? && params[:month].present?
      year = params[:year]            # => "2022"
      month = params[:month]          # => "5"
      month = format("%02d", month)   # => "05"
      @attendances = Attendance.all  
     
      @attendances.each do |at|
        years.store(at.id, at.worked_on.strftime("%Y"))     # => [id: "1", %Y: "2022"] next [id: "2", %Y: "2022"]
        months.store(at.id, at.worked_on.strftime("%m"))    # => [id: "1", %Y: "05"] next [id: "2", %Y: "05"]
      end
        # オブジェクト=>二次配列化 {id: "1", worked_on: "2022-05-01"} => [[id: "1"],[worked_on: "2022-05-01"]]
      years = years.to_a 
      months = months.to_a

      attendance_id_1 = []
      years.each do |y|               # => [1, "2022"]
        if y[1] == year               # y[1] => 配列の２個目 "2022"
          attendance_id_1 << y[0]
        end
      end
      attendance_id_2 = []
      months.each do |m| # => [1, "05"]
        if m[1] == month
          attendance_id_2 << m[0]
        end
      end
      attendance_date_id = attendance_id_1 + attendance_id_2
      attendance_date_id = attendance_date_id.select{|a| attendance_date_id.index(a)!=attendance_date_id.rindex(a)}.uniq
      @attendances = Attendance.where(id: attendance_date_id)
    end

  end

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :confirmation_one_month, :change_one_month])[:attendances]
    end

    def apply_overtime_params
      params.require(:user).permit(attendances: [:confirmation, :change])[:attendances]
    end

    def apply_one_month_params
      params.require(:user).permit(attendances: [:confirmation_one_month, :change_one_month])[:attendances]
    end

    def overtime_params
      params.require(:user).permit(attendance: [:scheduled_end_time, :next_day, :business_process, :confirmation])[:attendance]
    end

    def manager_params
      params.require(:user).permit(attendance: [:confirmation_manager])[:attendance]
    end

    def apply_manager_params
      params.require(:user).permit(attendances: [:confirmation_manager, :change_manager])[:attendances]
    end

    # beforeフィルター

    
end