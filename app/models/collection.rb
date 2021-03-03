# frozen_string_literal: true
# == Schema Information
#
# Table name: collections
#
#  id             :bigint(8)        not null, primary key
#  collectable_id :integer
#  ctype          :integer
#  account_id     :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Collection < ApplicationRecord
	belongs_to :account
  # belongs_to :, class_name: 'Account'

	after_create :increment_cache_counters
	after_destroy :decrement_cache_counters

	def increment_cache_counters
    account&.increment_count!(:musics_count)
  end

  def decrement_cache_counters
    account&.decrement_count!(:musics_count)
  end
end
