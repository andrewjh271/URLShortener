# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  short_url  :string           not null
#  long_url   :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'securerandom'
require_relative 'user'
require_relative 'visit'

class ShortenedUrl < ApplicationRecord
  validates :short_url, presence: true, uniqueness: true
  validates :long_url, presence:true
  validate :no_spamming
  validate :no_premium_max

  belongs_to(:submitter, {
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id
  })

  has_many(:visits, {
    class_name: :Visit,
    foreign_key: :url_id,
    primary_key: :id
  })

  has_many(:tags, {
    class_name: :Tagging,
    foreign_key: :url_id,
    primary_key: :id
  })

  has_many :tag_topics,
    through: :tags,
    source: :topic,
    dependent: :destroy

  has_many :visitors,
    -> { distinct },
    through: :visits,
    source: :user,
    dependent: :destroy

  def self.random_code
    code = SecureRandom.urlsafe_base64(16)
    ShortenedUrl.exists?(short_url: code) ? random_code : code
  end

  def self.generate(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: random_code)
  end

  def self.prune
    # Alternate syntax if string method weren't required:
    # ShortenedUrl.joins(:submitter).where(users: {email: "bmyfriend@hotmail.com"})

    # A LOT of unsuccessfull attempts: getting joins(:submitter) because of belongs_to association,
    # but users when referencing the table because that is the table name
    # shortened_url.created_at instead of just created_at
    ShortenedUrl.joins(:submitter).where('shortened_urls.created_at < ? AND users.premium IS FALSE', 2.days.ago).destroy_all
    # declaring 'dependent: :destroy' in the has_many associations allows destroy_all to delete those as well
  end

=begin
  SQL query I was going for above:
  <<-SQL
  SELECT *
  FROM shortened_urls
  INNER JOIN users ON shortened_urls.user_id = users.id
  WHERE
    shortened_urls.created_at < 7.days.ago
    AND users.premium = FALSE
  SQL
=end

  def num_clicks
    visits.count
  end

  def num_uniques
    visitors.count
  end

  def num_recent_uniques
    Visit.select(:user_id).distinct.where('url_id = ? AND created_at >= ?', id, 10.minutes.ago).count
  end

  private

  def no_premium_max
    unless User.find(user_id).premium ||
           self.class.select(:*).where(user_id: user_id).count < 5
      errors[:base] << 'Non-premium user cannot submit more than 5 URLS.'
    end
  end

  def no_spamming
    unless self.class.select(:*).where(
      'user_id = ? AND created_at >= ?', user_id, 1.minute.ago).count < 3
      errors[:base] << 'User cannot submit more than 3 URLS in 1 minute.'
    end
  end

end