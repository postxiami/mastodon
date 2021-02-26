# frozen_string_literal: true

class AccountMusicController < ApplicationController
  include AccountControllerConcern
  include SignatureVerification

  before_action :require_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_cache_headers

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!, unless: :whitelist_mode?

  def index
    respond_to do |format|
      format.html do
        expires_in 0, public: true unless user_signed_in?
        rows
      end
    end
  end

  private

  def rows
    return @rows if defined?(@rows)

    account = current_account
    if params[:content_type]
      if params[:content_type] == 'song'
        query = Track.joins("INNER JOIN collections ON collections.collectable_id = tracks.id AND ctype = 1 AND account_id = " + account[:id].to_s)
      end

      if params[:content_type] == 'album'
        query = Album.joins("INNER JOIN collections ON collections.collectable_id = albums.id AND ctype = 2 AND account_id = " + account[:id].to_s)
      end

      if params[:content_type] == 'artist'
        query = Artist.joins("INNER JOIN collections ON collections.collectable_id = artists.id AND ctype = 3 AND account_id = " + account[:id].to_s)
      end
    else
      query = Album.joins("INNER JOIN collections ON collections.collectable_id = albums.id AND ctype = 2 AND account_id = " + account[:id].to_s)
    end

    @rows = []
    if query
      @rows = query.page(params[:page]).per(40)
    end
    # scope = Follow.where(account: @account)
    # scope = scope.where.not(target_account_id: current_account.excluded_from_timeline_account_ids) if user_signed_in?
    # @rows = scope.recent.page(params[:page]).per(FOLLOW_PER_PAGE).preload(:target_account)
  end
end
