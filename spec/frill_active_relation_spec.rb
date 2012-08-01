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

require_relative '../lib/frill/active_record/association_decorator'

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

describe Frill::ActiveRecord::AssociationDecorator do
  before { Post.destroy_all; Blog.destroy_all; Comment.destroy_all }
  before { Frill.reset! }

  let!(:post) do
    Post.create.tap do |p|
      p.blog = Blog.create
      p.save
    end
  end

  let!(:decorated_module) do
    Module.new do
      include Frill

      def self.frill?(*)
        true
      end
    end
  end

  describe ".decorate(object, context)" do
    context "given an ActiveRecord object" do
      it "should decorate associated objects" do
        Frill::ActiveRecord::AssociationDecorator.decorate post, double(:context)
        blog_eigenclass = class << post.blog; self; end
        blog_eigenclass.included_modules.should include decorated_module
      end

      it "should not attempt to decorate nil associations" do
        comment = Comment.create
        Frill::ActiveRecord::AssociationDecorator.decorate comment, double(:context)
        post_eigenclass = class << comment.post; self; end
        post_eigenclass.included_modules.should_not include decorated_module
      end

      it "should lazily decorate collection associations" do
        post.comments << Comment.create << Comment.create
        Frill::ActiveRecord::AssociationDecorator.decorate post, double(:context)
        comments = post.comments
        comment = comments.first
        comment_eigenclass = class << comment; self; end
        comment_eigenclass.included_modules.should include decorated_module
      end
    end
  end
end
