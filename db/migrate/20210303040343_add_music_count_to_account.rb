class AddMusicCountToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :account_stats, :musics_count, :bigint
    change_column :account_stats, :musics_count, :bigint, default: 0
  end
  def down
    remove_column :account_stats, :musics_count
  end
end
