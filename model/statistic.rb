class Statistic < ActiveRecord::Base
  self.table_name = 'statistics'
  belongs_to :project
end