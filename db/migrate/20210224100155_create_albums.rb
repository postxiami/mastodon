class CreateAlbums < ActiveRecord::Migration[5.2]
  def change

    create_table :artists do |t|
      t.string :name
      t.string :cover
      t.string :country
      t.text :desc
      t.timestamps
    end

    create_table :albums do |t|
      t.string :name
      t.string :cover
      t.belongs_to :artist, index: true, foreign_key: true
      t.datetime :published_at
      t.text :desc
      t.timestamps
    end

    create_table :tracks do |t|
      t.string :name
      t.belongs_to :artist, index: true, foreign_key: true
      t.belongs_to :album, index: true, foreign_key: true
      t.integer :track_no
      t.timestamps
    end

    create_table :loves do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
