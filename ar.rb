require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3', 
  database: 'db/test.db'
)

%w(posts blogs comments).each do |table|
  ActiveRecord::Base.connection.execute(
    %(
      DROP TABLE 
        IF EXISTS 
        #{table}
    )
  )
end

ActiveRecord::Base.connection.execute(
  %(
    CREATE TABLE 
      posts(
        id INTEGER, 
        blog_id INTEGER,
        PRIMARY KEY(id ASC)
      )
  )
)

ActiveRecord::Base.connection.execute(
  %(
    CREATE TABLE 
      blogs(
        id INTEGER, 
        name VARCHAR,
        PRIMARY KEY(id ASC)
      )
  )
)

ActiveRecord::Base.connection.execute(
  %(
    CREATE TABLE 
      comments(
        id INTEGER, 
        post_id INTEGER,
        PRIMARY KEY(id ASC)
      )
  )
)


class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :comments
end

class Blog < ActiveRecord::Base
  has_many :posts
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

