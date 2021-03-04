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
end
