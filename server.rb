require 'sinatra'
require 'pg'
require_relative 'class_article'

get "/articles" do
  articles = Article.all
  erb :index, locals: {articles: articles}
end

get "/articles/submit" do
  article = Article.new
  erb :article_submit, locals: {article: article}
end

post '/articles/submit' do
  article = Article.new(params)

  if article.save?
    return redirect '/articles'
  else
    return erb :article_submit, locals: {article: article}
  end

end
