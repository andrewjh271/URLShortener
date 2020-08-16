# == Schema Information
#
# Table name: votes
#
#  id         :bigint           not null, primary key
#  positive   :boolean
#  negative   :boolean
#  user_id    :integer          not null
#  url_id     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
