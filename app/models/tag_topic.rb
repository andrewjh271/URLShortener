# == Schema Information
#
# Table name: tag_topics
#
#  id         :bigint           not null, primary key
#  topic      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class TagTopic < ApplicationRecord
  has_many(:tags, {
    class_name: :Tagging,
    foreign_key: :topic_id,
    primary_key: :id
  })

  has_many :tagged_urls,
    through: :tags,
    source: :url

  def popular_links
    tagged_urls.sort { |a, b| b.num_clicks <=> a.num_clicks }.first(3).map do |url|
      "#{url.short_url}: #{url.num_clicks} visits"
    end
  end
end
