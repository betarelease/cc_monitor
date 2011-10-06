class AddProject < ActiveRecord::Migration
  def up
    create_table :projects, :force => true do |t|
      t.column :name, :text
      t.column :activity, :text
      t.column :last_build_status, :text
      t.column :last_build_label, :text
      t.column :last_build_time, :datetime
      t.column :web_url, :text
      t.column :success_count, :integer, :default => 0, :null => false
      t.column :last_successful_build, :datetime
      t.column :last_failed_build, :datetime
      t.column :failure_count, :integer, :default => 0, :null => false
      t.column :build_count, :integer, :default => 0, :null => false
    end
  end
  
  def down
    drop_table :projects
  end
end