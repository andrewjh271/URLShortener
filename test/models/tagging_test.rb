# == Schema Information
#
# Table name: taggings
#
#  id         :bigint           not null, primary key
#  topic_id   :integer          not null
#  url_id     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
