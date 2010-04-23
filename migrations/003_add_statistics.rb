class AddStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics, :force => true do |t|
      t.column :date, :date
      t.column :result, :boolean
      t.column :project_id, :integer
    end
  end
  
  def self.down
    drop_table :statistics
  end
end