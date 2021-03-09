class AddMusicCountToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :account_stats, :musics_count, :bigint
    safety_assured do
      change_column_default :account_stats, :musics_count, 0
    end
  end
  def down
    remove_column :account_stats, :musics_count
  end
end
