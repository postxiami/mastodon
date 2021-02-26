# frozen_string_literal: true
# == Schema Information
#
# Table name: tracks
#
#  id          :bigint(8)        not null, primary key
#  name        :string
#  artist_name :string
#  album_name  :string
#  artist_id   :bigint(8)
#  album_id    :bigint(8)
#  track_no    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Track < ApplicationRecord
	include Paginable
	
	has_one :album
	has_one :artist
end
