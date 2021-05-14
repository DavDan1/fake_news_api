class Api::ArticlesController < ApplicationController
  before_action :authenticate_user!

  def index
    articles = Article.all.most_recent
    if articles == []
      render json: { articles: articles }, status: 204
    else
      render json: articles, each_serializer: ArticlesIndexSerializer
    end
  end

  def show
    article = Article.find(params[:id])
    render json: article, serializer: ArticlesShowSerializer
  rescue ActiveRecord::RecordNotFound => e
    render json: { error_message: 'Article does not exist' }, status: 404
  end

  def create
    unless current_user.role == 'journalist'
      render json: { error_message: 'You dont have access' }, status: 403 and return
    end

    article = current_user.articles.create(params[:article].permit(:title, :teaser, :body))
    render json: { message: 'Your article has been successfully created!' }, status: 201
  end
end