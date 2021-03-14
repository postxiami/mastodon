# == Schema Information
#
# Table name: albums
#
#  id           :bigint(8)        not null, primary key
#  name         :string
#  cover        :string
#  artist_name  :string
#  artist_id    :bigint(8)
#  published_at :datetime
#  play_count   :integer
#  desc         :text
#  company      :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Album < ApplicationRecord
	include Paginable
	has_many :tracks
	belongs_to :artist
	has_and_belongs_to_many :music_tags
end
