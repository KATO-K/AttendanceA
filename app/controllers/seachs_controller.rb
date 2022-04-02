class Users::SearchesController < ApplicationController
  def index
      @users = User.search(params[:keyword])
      @search_word = params[:keyword]
  end    
end