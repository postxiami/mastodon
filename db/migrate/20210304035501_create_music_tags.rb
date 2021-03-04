class CreateMusicTags < ActiveRecord::Migration[5.2]
  def change
    create_table :music_tags do |t|
      t.string :name
      t.text :desc

      t.timestamps
    end

    create_join_table :albums, :music_tags do |t|
      t.index :music_tag_id
      t.index [:music_tag_id, :album_id], unique: true
    end

    create_join_table :artists, :music_tags do |t|
      t.index :music_tag_id
      t.index [:music_tag_id, :artist_id], unique: true
    end

    # create_table :albums_tags do |t|
    # 	t.bigint :album_id, null: false
	   #  t.bigint :tag_id, null: false
    # end

    # create_table :artists_tags do |t|
    # 	t.bigint :artist_id, null: false
	   #  t.bigint :tag_id, null: false
    # end
    # add_index :albums_tags, [:album_id, :music_tag_id], unique: true
    # add_index :artists_tags, [:artist_id, :music_tag_id], unique: true
    add_index :music_tags, [:name], unique: true
  end
end
