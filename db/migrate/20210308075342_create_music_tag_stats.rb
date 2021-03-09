class CreateMusicTagStats < ActiveRecord::Migration[5.2]
  def change
    create_table :music_tag_stats do |t|
      t.belongs_to :music_tags, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      # t.bigint :songs_count, null: false, default: 0
      t.bigint :albums_count, null: false, default: 0
      t.bigint :artists_count, null: false, default: 0

      t.timestamps
    end
  end
end
