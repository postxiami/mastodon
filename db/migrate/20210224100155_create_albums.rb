class CreateAlbums < ActiveRecord::Migration[5.2]
  def change

    create_table :artists do |t|
      t.string :name
      t.string :cover
      t.string :alias
      t.string :gender
      t.string :country
      t.integer :play_count
      t.text :desc
      t.timestamps
    end

    create_table :albums do |t|
      t.string :name
      t.string :cover
      t.string :artist_name
      t.belongs_to :artist, index: true
      t.datetime :published_at
      t.integer :play_count
      t.text :desc
      t.string :company
      t.timestamps
    end

    create_table :tracks do |t|
      t.string :name
      t.string :artist_name
      t.string :album_name
      t.belongs_to :artist, index: true
      t.belongs_to :album, index: true
      t.integer :track_no
      t.timestamps
    end

    create_table :collections do |t|
      t.integer :collectable_id
      t.integer :ctype
      t.integer :account_id
      t.timestamps
    end

    add_index :collections, [:collectable_id, :ctype, :account_id], unique: true
  	add_index :tracks, [:name, :artist_name, :album_name], unique: true
  	add_index :albums, [:name, :artist_name], unique: true
    add_index :albums, [:company]
  	add_index :artists, [:name, :country], unique: true
  end
end
