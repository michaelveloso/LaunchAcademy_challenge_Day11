require 'pg'

class Article

  attr_accessor :title, :url, :description, :errors

  def self.all
    articles = []
    raw_articles = get_articles
    raw_articles.each do |article_row|
      articles << Article.new(article_row)
    end
    articles
  end

  def initialize(info_hash={})
    @title = info_hash["title"]
    @url = info_hash["url"]
    @description = info_hash["description"]
    @errors = []
  end

  def save?
    valid = valid?
    if valid
      self.class.db_connection {|conn| conn.exec_params("INSERT INTO articles VALUES ($1, $2, $3)", [title, url, description])}
    end
    valid
  end

  private

  def self.db_connection
    begin
      connection = PG.connect(dbname: "news_aggregator_development")
      yield(connection)
    ensure
      connection.close
    end
  end

  def self.get_articles
    db_connection { |conn| conn.exec("SELECT * FROM articles")}
  end

  def title_valid?
    valid = title.length > 0
    errors << "Invalid title! Must be at least length 1." unless valid
    valid
  end

  def url_valid?
    valid = url =~ /[.]/
    errors << "Invalid URL!" unless valid
    valid
  end

  def description_valid?
    valid = description.length >= 20
    errors << "Invalid description: must be more than 20 letters." unless valid
    valid
  end

  def new_url?
    article_check = self.class.db_connection {|conn| conn.exec("SELECT * FROM articles WHERE url = '#{url}' LIMIT 1")}
    valid = !article_check.any?
    errors << "This URL has already been logged" unless valid
    valid
  end

  def valid?
    valid1 = title_valid?
    valid2 = description_valid?
    valid3 = url_valid?
    valid4 = new_url?
    valid1 && valid2 && valid3 && valid4
  end

end
