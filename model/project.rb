class Project < ActiveRecord::Base
  set_table_name 'projects'
  
  has_many :statistic
  
  def self.find_or_create( feed )
    values = {}
    feed.attributes.each do |name, value|
      values.merge!( name.underscore.to_sym => value.to_s )
    end
    Project.find_or_create_by_name( values[ :name ] )
  end

  def record!( feed )
    old_label = last_build_label
    populate( feed )
    unless old_label == feed.attributes[ 'lastBuildLabel' ]
      record_success! if last_build_status.include? "Success"
      record_failure! if last_build_status.include? "Failure"
    end
  end
  
  def health
    self.success_count * 100/self.build_count
  end
  
  def sickness
    100 - health
  end
  
  def successes
    success_count || 0
  end
  
  def failures
    failure_count || 0
  end
  
  def latest_build_time
    value = self.last_build_time || Time.now
    value.strftime( "at %I:%M%p" )
  end
  
  def today_success
    count = statistic.select{ |s| s.result == true && s.date == Date.today }.size
    number = count * 100/today_count
  end
    
  def today_failure
    count = statistic.select{ |s| s.result == false && s.date == Date.today }.size
    number = count * 100/today_count
  end

  def today_count
    today_count = statistic.select{ |s| s.date == Date.today }.size
    today_count = today_count == 0 ? 100 : today_count
  end
  
private

  def populate( feed )
    self.last_build_time = feed.attributes[ 'lastBuildTime' ]
    self.last_build_status = feed.attributes[ 'lastBuildStatus' ]
    self.last_build_label = feed.attributes[ 'lastBuildLabel' ]
    self.activity = feed.attributes[ 'activity' ]
    self.web_url = feed.attributes[ 'webUrl' ]
  end
  
  def record_failure!
    self.failure_count += 1
    self.last_failed_build = self.last_build_time
    self.build_count += 1
    self.statistic << Statistic.new( :date => Date.today, :result => false )
    save!
  end

  def record_success!
    self.success_count +=1
    self.last_successful_build = self.last_build_time
    self.build_count += 1
    self.statistic << Statistic.new( :date => Date.today, :result => true )
    save!
  end
  
end