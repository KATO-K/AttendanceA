class BasesController < ApplicationController

  
  before_action :logged_in_user, only: [:show, :new, :index, :edit, :update, :destroy]
  before_action :admin_user, only: [:show, :new, :index, :edit, :update, :destroy]

  def index
    @bases = Base.all
  end

  def new
    @base = Base.new
  end
  
  def edit
    @base = Base.find(params[:id])
  end

  def update
    @base = Base.find(params[:id])
    if @base.update(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to bases_url
    else
      render :edit      
    end
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to bases_url
    else
      render :new
    end
  end

  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_url
  end

  private

  def base_params
    params.require(:base).permit(:number, :name, :kind)
  end

end