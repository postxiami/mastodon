# == Schema Information
#
# Table name: music_tags
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  desc       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MusicTag < ApplicationRecord
	has_one :music_tag_stat, dependent: :destroy

	delegate :albums_count,
           :albums_count=,
           :artists_count,
           :artists_count=,
           :increment_count!,
           :decrement_count!,
           to: :music_tag_stat

  after_save :save_music_tag_stat

  def music_tag_stat
    super || build_music_tag_stat
  end

  private
  def save_music_tag_stat
    return unless music_tag_stat&.changed?
    music_tag_stat.save
  end
end
