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
end
