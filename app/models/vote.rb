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
class Vote < ApplicationRecord
  validate :positive_or_negative

  belongs_to(:url, {
    class_name: :ShortenedUrl,
    foreign_key: :url_id,
    primary_key: :id
  })

  belongs_to(:user, {
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id
  })

  def save
    self.class.where(user_id: user_id, url_id: url_id).delete_all
    super
  end

  def save!
    self.class.where(user_id: user_id, url_id: url_id).delete_all
    super
  end

  private

  def positive_or_negative
    unless positive && !negative || negative && !positive
      errors[:base] << 'Positive OR negative must be true.'
    end
  end
end
