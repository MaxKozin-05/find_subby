class UpdateJobStatusesAndBlocks < ActiveRecord::Migration[7.1]
  def up
    add_column :jobs, :starts_on, :date
    add_column :jobs, :ends_on, :date
    add_column :jobs, :calendar_blocked, :boolean, default: false, null: false

    create_table :job_blocks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.date :ends_on, null: false

      t.timestamps
    end

    # Remap legacy statuses to new pipeline values
    execute <<~SQL
      UPDATE jobs SET status = 0 WHERE status IN (0, 1);
      UPDATE jobs SET status = 1 WHERE status = 2;
      UPDATE jobs SET status = 2 WHERE status = 3;
      UPDATE jobs SET status = 3 WHERE status = 4;
      UPDATE jobs SET status = 4 WHERE status = 5;
      UPDATE jobs SET status = 5 WHERE status IN (6, 7);
    SQL
  end

  def down
    execute <<~SQL
      UPDATE jobs SET status = 6 WHERE status = 5;
      UPDATE jobs SET status = 5 WHERE status = 4;
      UPDATE jobs SET status = 4 WHERE status = 3;
      UPDATE jobs SET status = 3 WHERE status = 2;
      UPDATE jobs SET status = 2 WHERE status = 1;
      UPDATE jobs SET status = 0 WHERE status = 0;
    SQL

    drop_table :job_blocks

    remove_column :jobs, :calendar_blocked
    remove_column :jobs, :ends_on
    remove_column :jobs, :starts_on
  end
end
