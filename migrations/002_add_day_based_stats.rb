class AddDayBasedStats < ActiveRecord::Migration
  def self.up
    add_column :projects, :failure_count_today, :integer, :default => 0, :null => false
    add_column :projects, :build_count_today, :integer, :default => 0, :null => false
    add_column :projects, :success_count_today, :integer, :default => 0, :null => false
  end
  
  def self.down
    remove_column :projects, :failure_count_today
    remove_column :projects, :build_count_today
    remove_column :projects, :success_count_today
  end
end