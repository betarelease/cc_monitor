class Statistic < ActiveRecord::Base
  set_table_name 'statistics'
  belongs_to :project
end