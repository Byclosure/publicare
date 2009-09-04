ENV['AUTOFEATURE'] = "true"
ENV['RSPEC'] = "true"

dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)
$_spec_spec = true # Prevents Kernel.exit in various places

require 'spec'
require 'spec/mocks'

require "facets"
require "ruby-debug"
Debugger.start

require "active_record"
ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table "news", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "books", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publications", :force => true do |t|
    t.integer  "content_id"
    t.string   "content_type"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end

require 'acts_as_publication' unless defined?(ActsAsPublication)
require 'publication'

ActiveRecord::Base.class_eval do
  include ActsAsPublication
end

class News < ActiveRecord::Base
  acts_as_publication
end

class Book < ActiveRecord::Base
  acts_as_publication  
end



def jruby?
  ::RUBY_PLATFORM == 'java'
end

Spec::Runner.configure do |config|
   config.append_after(:each) do
     ActiveRecord::Base.descendents.each(&:delete_all)
   end
   
   config.predicate_matchers[:be_published] = :published?
end