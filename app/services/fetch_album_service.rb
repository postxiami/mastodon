# frozen_string_literal: true

class FetchAlbumService < BaseService

  def call(album)
    @album = album
    # @url    = parse_urls
    @url = "https://www.last.fm/music/" + @album[:artist_name] +"/" + @album[:name]
    @url = @url.gsub(" ", " ").gsub(" ", "+").to_s

    @metadata = {}
    @metadata[:url] = @url

    Request.new(:get, @url).add_headers('Accept' => 'text/html', 'User-Agent' => Mastodon::Version.user_agent + ' Bot').perform do |res|
      if res.code == 200 && res.mime_type == 'text/html'
        @html_charset = res.charset
        @html = res.body_with_limit
      else
        @html_charset = nil
        @html = nil
      end
    end
    
    return @metadata if @html.nil?

    detector = CharlockHolmes::EncodingDetector.new
    detector.strip_tags = true

    guess      = detector.detect(@html, @html_charset)
    encoding   = guess&.fetch(:confidence, 0).to_i > 60 ? guess&.fetch(:encoding, nil) : nil
    page       = Nokogiri::HTML(@html, nil, encoding)

    # return if @url.nil? || @status.preview_cards.any?
    # @url = @url.to_s
    # RedisLock.acquire(lock_options) do |lock|
    #   if lock.acquired?
    #     @card = PreviewCard.find_by(url: @url)
    #     process_url if @card.nil? || @card.updated_at <= 2.weeks.ago || @card.missing_image?
    #   else
    #     raise Mastodon::RaceConditionError
    #   end
    # end
    if (page.css('.album-overview-cover-art').length)
      cover_tag = page.css('.album-overview-cover-art img')
      @metadata[:cover] = cover_tag[0] ? cover_tag[0].attr("src") : nil
    end
   
    all_tags = page.css('.col-sm-8 .tags-list .tag a')
    @metadata[:tags] = all_tags.map { |el|
      el.content
    }

    @metadata[:tracks] = page.css('.chartlist tbody tr').map { |tag|
      track_rank = tag.css('.chartlist-index')[0].content
      track_name = tag.css('.chartlist-name')[0].content
      track_duration = tag.css('.chartlist-duration')[0].content
      track_count = tag.css('.chartlist-count-bar-value')[0] ? tag.css('.chartlist-count-bar-value')[0].content : nil
      track = {
        name: track_name.strip,
        rank: track_rank.strip,
        duration: track_duration.strip,
        count: track_count.strip
      }
      track
    }

    @metadata[:stat] = page.css(".header-new-info-desktop .header-metadata-tnew-item").map { |tag|
      stat = {
        name: tag.css('h4')[0].content.strip,
        value: tag.css('.intabbr')[0].content.strip
      }
      stat
    }

    # @metadata[]

    if page.css(".about-artist").length
      artist_meta = {}
      artist_meta[:name] = page.css(".about-artist .about-artist-name")[0].content.strip
      artist_meta[:listeners] = page.css(".about-artist .about-artist-listeners")[0].content.strip
      artist_meta[:cover] = page.css(".about-artist .gallery-preview-image--0 img")[0] ? page.css(".about-artist .gallery-preview-image--0 img")[0].attr('src') : nil
      artist_meta[:tags] = page.css(".about-artist-tags .tag").map { |el|
        el.content
      }
      @metadata[:artist] = artist_meta
    end 

    if page.css('.metadata-column dt').length > 1
      @metadata[:pub] = page.css('.metadata-column dt')[1].next_element.text
    end
    @metadata[:name] = page.css('.header-new-title')[0].content.strip
    @metadata[:exists] = []

    @metadata[:tracks].each { |track|
      is_in = Track.find_by(name: track[:name], album_id: @album.id)
      if is_in
        @metadata[:exists].push(is_in)
        if is_in.track_no.nil?
          is_in.track_no = track[:rank].to_i
          is_in.save
        end
      else
        # create track
        album_track = Track.new
        album_track.artist_id = @album.artist_id
        album_track.album_name = @album.name
        album_track.artist_name = @album.artist_name
        album_track.name = track[:name]
        album_track.track_no = track[:rank].to_i
        @album.tracks << album_track
      end
      # if is_in.nil?
      #   album_track = Track.new
      #   album_track.artist_id = @album.artist_id
      #   album_track.album_name = @album.name
      #   album_track.artist_name = @album.artist_name
      #   album_track.name = track[:name]
      #   album_track.track_no = track[:rank].to_i
      #   @album.tracks << album_track
      # end
    }

    if @metadata[:tags]
      @metadata[:tags].each { |tag_name|  
        tag = MusicTag.where({name: tag_name})
        .first_or_create({name: tag_name})
        begin
          @album.music_tags << tag unless @album.music_tags.include?(tag)
          tag.increment_count!(:albums_count) unless @album.music_tags.include?(tag)
        rescue ActiveRecord::RecordNotUnique
          puts "eists"
        end
      }
    end

    if @metadata[:artist] && @metadata[:artist][:tags]
      @metadata[:artist][:tags].each { |tag_name|  
        tag = MusicTag.where({name: tag_name})
        .first_or_create({name: tag_name})
        begin
          @album.artist.music_tags << tag unless @album.artist.music_tags.include?(tag)
          tag.increment_count!(:albums_count) unless @album.artist.music_tags.include?(tag)
        rescue ActiveRecord::RecordNotUnique
          puts "eists"
        end
      }
    end

    # save album meta
    if @album.cover.nil? && @metadata[:cover]
      @album.cover = @metadata[:cover]
    end

    @album.save

    # save artist meta
    if @metadata[:artist] && @album.artist
      @album.artist.cover = @metadata[:artist][:cover]
      @album.artist.save
    end

    # @album
    @metadata
    @album.artist.music_tags
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Addressable::URI::InvalidURIError, Mastodon::HostValidationError, Mastodon::LengthValidationError => e
    Rails.logger.debug "Error fetching link #{@url}: #{e}"
    nil
  end

  private

  # def process_url
  #   @card ||= PreviewCard.new(url: @url)

  #   attempt_oembed || attempt_opengraph
  # end

  # def html
  #   return @html if defined?(@html)

  #   Request.new(:get, @url).add_headers('Accept' => 'text/html', 'User-Agent' => Mastodon::Version.user_agent + ' Bot').perform do |res|
  #     if res.code == 200 && res.mime_type == 'text/html'
  #       @html_charset = res.charset
  #       @html = res.body_with_limit
  #     else
  #       @html_charset = nil
  #       @html = nil
  #     end
  #   end
  # end

  # def attach_card
  #   @status.preview_cards << @card
  #   Rails.cache.delete(@status)
  # end

  def meta_property(page, property)
    page.at_xpath("//meta[contains(concat(' ', normalize-space(@property), ' '), ' #{property} ')]")&.attribute('content')&.value || page.at_xpath("//meta[@name=\"#{property}\"]")&.attribute('content')&.value
  end

  def lock_options
    { redis: Redis.current, key: "fetch:#{@url}" }
  end
end
