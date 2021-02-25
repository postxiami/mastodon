# frozen_string_literal: true

class Api::V1::Music::CollectionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  # before_action :set_account

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
	row = Track.where(item).first_or_create(crate_item)
	row
  end
  
  def create_artist(data_item)
	item = {
		name: data_item[:name]
	}
	create_item = {
		name: data_item[:name]
	}
	if data_item[:cover]
		create_item[:cover] = data_item[:cover]
	end
	if data_item[:desc]
		create_item[:desc] = data_item[:desc]
	end
	if data_item[:country]
		create_item[:country] = data_item[:country]
	end
	row = Artist.where(item).first_or_create(create_item)
	row
  end 
  def create_album(data_item)
	item = {
		name: data_item[:name],
		artist_name: data_item[:artist_name]
	}
	create_item = {
		name: data_item[:name],
		artist_name: data_item[:artist_name]
	}
	if data_item[:cover]
		create_item[:cover] = data_item[:cover]
	end
	if data_item[:desc]
		create_item[:desc] = data_item[:desc]
	end
	if data_item[:published_at]
		create_item[:published_at] = data_item[:published_at]
	end
	row = Album.where(item).first_or_create(create_item)
	row
  end

  # def set_account
  #   @account = Account.find(params[:account_id])
  # end

  # def relationships_presenter
  #   AccountRelationshipsPresenter.new([@account.id], current_user.account_id)
  # end
end
