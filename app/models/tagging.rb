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
class Tagging < ApplicationRecord
  belongs_to(:url, {
    class_name: :ShortenedUrl,
    foreign_key: :url_id,
    primary_key: :id
  })

  belongs_to(:topic, {
    class_name: :TagTopic,
    foreign_key: :topic_id,
    primary_key: :id
  })
end
