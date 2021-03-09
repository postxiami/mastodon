class AddMusicCountToAccount < ActiveRecord::Migration[5.0]
  def change
  	safety_assured do
      add_column :account_stats, :musics_count, :bigint, null: false, default: 0
    end
  end
end