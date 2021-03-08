# frozen_string_literal: true

class Api::V1::Music::CollectionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  
  def create
		@account = current_account
		all_results = {}
		[:songs, :albums, :artists].each{ |h|
			if params[h]
				reults = []
				params[h].map { |data_item|
					current_type = 1
					if h == :songs
						row = create_track data_item
					end
					if h == :albums
						row = create_album data_item
						current_type = 2
					end
					if h == :artists
						row = create_artist data_item
						current_type = 3
					end
					if row 
						collect_item = {
							collectable_id: row[:id],
							ctype: current_type,
							account_id: @account[:id]
						}
						follow = Collection.where(collect_item).first_or_create(collect_item)
						reults.push(follow ? follow[:id] : 0)
					else 
						reults.push(0)
					end
				}
			    all_results[h] = reults
			end
		}
		render json: all_results
  end
  
  private
  
  def create_track(data_item)
		# auto create
		artist = create_artist({
			name: data_item[:artist_name],
			cover: data_item[:artist_cover]
		})
		album = create_album({
			name: data_item[:album_name],
			artist_name: data_item[:artist_name],
			cover: data_item[:cover]
		})
		item = {
			name: data_item[:name],
			artist_name: data_item[:artist_name],
			album_name: data_item[:album_name],
		}
		crate_item = {
			name: data_item[:name],
			artist_name: data_item[:artist_name],
			album_name: data_item[:album_name],
			artist_id: artist[:id],
			album_id: album[:id]
		}
		Track.where(item).first_or_create(crate_item)
  end
  
  def create_artist(data_item)
		item = {
			name: data_item[:name]
		}
		create_item = {
			name: data_item[:name]
		}

		fill_keys = [:cover, :alias, :gender, :play_count, :desc, :country]
		fill_keys.each { |key|
			if data_item[key]
				create_item[key] = data_item[key]
			end
		}

		# increment_count!
		artist = Artist.where(item).first_or_create(create_item)
		if(data_item[:tags])
			tags = data_item[:tags].each { |e|  
				tag_name = e[:name]
				tag = MusicTag.where({
					name: tag_name
				}).first_or_create({
					name: tag_name
				})
				begin
					artist.music_tags << tag
					tag.increment_count!(:artists_count)
				rescue ActiveRecord::RecordNotUnique
				end
			}
		end
		artist
  end
  
  def create_album(data_item)
		item = {
			name: data_item[:name],
			artist_name: data_item[:artist_name]
		}
		create_item = {}
		artist = create_artist({ name: data_item[:artist_name]})
		if artist
			create_item[:artist_id] = artist[:id]
		end

		fill_keys = [:name, :artist_name, :cover, :published_at, :play_count, :desc, :company]
		fill_keys.each { |key|
			if data_item[key]
				create_item[key] = data_item[key]
			end
		}
		Album.where(item).first_or_create(create_item)
  end
end
