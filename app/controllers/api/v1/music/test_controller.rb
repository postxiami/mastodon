# frozen_string_literal: true

class Api::V1::Music::TestController < Api::BaseController

  def index
    album = Album.find_by(id: params[:id])
    metadata = FetchAlbumService.new.call(album)
  	render json: metadata
  end
end
