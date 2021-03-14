# frozen_string_literal: true
# == Schema Information
#
# Table name: artists
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  cover      :string
#  alias      :string
#  gender     :string
#  country    :string
#  play_count :integer
#  desc       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Artist < ApplicationRecord
	include Paginable

	has_many :albums

	has_and_belongs_to_many :music_tags, 
	:after_create => :increment_cache_counters, 
	:after_destroy => :decrement_cache_counters

	# def increment_cache_counters(_music_tag)
	# 	_music_tag.increment_count!(:artists_count)
	# end

	# def decrement_cache_counters(_music_tag)
	# 	_music_tag.decrement_count!(:artists_count)
	# end
end
