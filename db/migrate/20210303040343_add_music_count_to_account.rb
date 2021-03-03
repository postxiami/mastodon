class AddMusicCountToAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :account_stats, :musics_count, :bigint, null: false, default: 0
  end
end
