require 'active_record'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => 'db.sqlite'
class Project < ActiveRecord::Base
  set_table_name 'projects'
end

