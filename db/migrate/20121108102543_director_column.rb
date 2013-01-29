class DirectorColumn < ActiveRecord::Migration
  def up
    add_column(:movies,:director,:string)
  end

  def down
    drop_table :movies
  end
end
