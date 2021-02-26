# frozen_string_literal: true

class Api::V1::Music::ListController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!
  # before_action :set_account
  after_action :insert_pagination_headers

  def index
  	account = current_account
  	if params[:content_type] == 'song'
  		query = Track.joins("INNER JOIN collections ON collections.collectable_id = tracks.id AND ctype = 1 AND account_id = " + account[:id].to_s)
  	end

  	if params[:content_type] == 'album'
  		query = Album.joins("INNER JOIN collections ON collections.collectable_id = albums.id AND ctype = 2 AND account_id = " + account[:id].to_s)
  	end

  	if params[:content_type] == 'artist'
  		query = Artist.joins("INNER JOIN collections ON collections.collectable_id = artists.id AND ctype = 3 AND account_id = " + account[:id].to_s)
  	end

  	@rows = []
  	if query
	  	@rows = query.paginate_by_max_id(
		  	limit_param(100),
		    params[:max_id],
		   	params[:since_id]
		  )
	  end
	  data = {
	  	rows: @rows,
	  	params: params
	  }
		render json: data
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_music_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @rows.empty?
      api_v1_music_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @rows.last.id
  end

  def pagination_since_id
    @rows.first.id
  end

  def records_continue?
    @rows.size == limit_param(100)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
