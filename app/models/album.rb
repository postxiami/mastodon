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
#  desc         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Album < ApplicationRecord
end
