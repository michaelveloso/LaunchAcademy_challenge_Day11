require 'pg'
require 'pry'

DBNAME = "news_aggregator_development"

def db_connection
  begin
    connection = PG.connect(dbname: DBNAME)
    yield(connection)
  ensure
    connection.close
  end
end

data = db_connection {|conn| conn.exec("SELECT * FROM articles")}
binding.pry
