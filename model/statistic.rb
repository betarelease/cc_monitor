class Statistic < ActiveRecord::Base
  belongs_to :project
  
  def self.today_success(project)
    self.count(:conditions => {:project_id => project.id, :result => true, :date => Date.today})
  end
  
  def self.today_failure(project)
    self.count(:conditions => {:project_id => project.id, :result => false, :date => Date.today})
  end
  
  def self.today(project)
    self.count(:conditions => {:project_id => project.id, :date => Date.today})
  end
  
  def self.yesterday(project)
    Statistic.count(:conditions => {:project_id => project.id, :result => false, :date => Date.yesterday})
  end

  def self.last_week
    [((Date.today-7)..Date.today).to_s(:db)]
  end
  
  def self.week(project)
    self.count(:conditions => {:project_id => project.id, :date => last_week})
  end

  def self.week_success(project)
    last_week = (Date.today..(Date.today-7)).to_s(:db)
    self.count(:conditions => {:project_id => project.id, :result => true, :date => last_week})
  end
  
  def self.week_failure(project)
    last_week = (Date.today..(Date.today-7)).to_s(:db)
    self.count(:conditions => {:project_id => project.id, :result => false, :date => last_week})
  end
  
end