# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint           not null, primary key
#  short_url  :string           not null
#  long_url   :string           not null
#  user_id    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'securerandom'
require_relative 'user'

class ShortenedUrl < ApplicationRecord
  validates :short_url, presence: true, uniqueness: true
  validates :long_url, presence:true

  belongs_to(:submitter, {
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id
  })

  def self.random_code
    code = SecureRandom.urlsafe_base64(16)
    ShortenedUrl.exists?(short_url: code) ? random_code : code
  end

  def self.generate(user, long_url)
    ShortenedUrl.create!(user_id: user.id, long_url: long_url, short_url: random_code)
  end
end
