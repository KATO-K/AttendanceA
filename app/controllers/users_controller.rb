class UsersController < ApplicationController
  before_action :set_user, only: [:show, :show_confirmation, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:show, :show_confirmation,:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :superior_or_correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: [:show, :show_confirmation]

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    if params[:id] == "1"
      redirect_back(fallback_location: root_path)
    end
    @worked_sum = @attendances.where.not(started_at: nil).count
    @approval = @user.attendances.find_by(worked_on: @first_day)

    @approvals = Attendance.find_by(confirmation: "上長A")
    @approvals.nil? ? @approvals = @approvals_overtime = Attendance.find_by(confirmation: "なし") : 
                                   @approvals_overtime = Attendance.find_by(confirmation: "上長A") 
    @approvals = Attendance.find_by(confirmation_one_month: "上長A")
    @approvals.nil? ? @approvals = @approvals_one_month = Attendance.find_by(confirmation_one_month: "なし") : 
                                   @approvals_one_month = Attendance.find_by(confirmation_one_month: "上長A") 
    @approvals = Attendance.find_by(confirmation_manager: "上長A")
    @approvals.nil? ? @approvals = @approvals_manager = Attendance.find_by(confirmation_manager: "なし") : 
                                   @approvals_manager = Attendance.find_by(confirmation_manager: "上長A") 

    @approval_manager_sum = Attendance.where(confirmation_manager: "上長A").count
    @approval_one_month_sum = Attendance.where(confirmation_one_month: "上長A").count
    @approval_overtime_sum = Attendance.where(confirmation: "上長A").count

  end

  def show_confirmation
    @worked_sum = @attendances.where.not(started_at: nil).count
    @approval = @user.attendances.find_by(worked_on: @first_day)

    @approvals = Attendance.find_by(confirmation: "上長A")
    @approvals.nil? ? @approvals = @approvals_overtime = Attendance.find_by(confirmation: "なし") : 
                                   @approvals_overtime = Attendance.find_by(confirmation: "上長A") 
    @approvals = Attendance.find_by(confirmation_one_month: "上長A")
    @approvals.nil? ? @approvals = @approvals_one_month = Attendance.find_by(confirmation_one_month: "なし") : 
                                   @approvals_one_month = Attendance.find_by(confirmation_one_month: "上長A") 
    @approvals = Attendance.find_by(confirmation_manager: "上長A")
    @approvals.nil? ? @approvals = @approvals_manager = Attendance.find_by(confirmation_manager: "なし") : 
                                   @approvals_manager = Attendance.find_by(confirmation_manager: "上長A") 
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    @users = User.paginate(page: params[:page], per_page: 20)
    @user = User.find(params[:id])
    if @user.update(basic_info_params)
      flash[:success] = "アカウント情報を更新しました。"
      redirect_to users_url
    else
      render :index
    end
  end

  def in_attendance
    @users = User.all.includes(:attendances)
  end

  def import
    if params[:file].blank?
      flash[:danger] = "ファイルを選択してください"
      redirect_to users_url 
    else 
      User.import(params[:file])
      flash[:success] = "アカウント情報を追加しました。"
      redirect_to users_url
    end
  end
  
  def basic_info
  end

  private

    def user_params
      params.require(:user).permit(:name, :email,:password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:name, :email, :password, :affiliation, :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end

   
end
