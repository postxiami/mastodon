# == Schema Information
#
# Table name: music_tag_stats
#
#  id            :bigint(8)        not null, primary key
#  music_tag_id  :bigint(8)        not null
#  albums_count  :bigint(8)        default(0), not null
#  artists_count :bigint(8)        default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class MusicTagStat < ApplicationRecord
	belongs_to :music_tag, inverse_of: :music_tag_stat

  def increment_count!(key)
    update(key => public_send(key) + 1)
  end

  def decrement_count!(key)
    update(key => [public_send(key) - 1, 0].max)
  end
end
