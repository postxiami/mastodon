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
end
