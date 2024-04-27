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

  # A lot of direct SQL, much preferable to the huge number of queries the above method generates.
  # ShortenedUrl.find_by_sql will return an array of ShortenedUrl objects with properties/methods based
  # on the values the SQL returns
  def popular_links2
    sql = <<-SQL.squish
      SELECT shortened_urls.short_url, COUNT(*) AS count
      FROM shortened_urls
      INNER JOIN taggings ON taggings.url_id = shortened_urls.id
      INNER JOIN tag_topics ON taggings.topic_id = tag_topics.id
      INNER JOIN visits ON visits.url_id = shortened_urls.id
      WHERE tag_topics.id = #{id}
      GROUP BY shortened_urls.id
      ORDER BY COUNT(*) DESC
      LIMIT(3);
    SQL
    # result = ApplicationRecord.connection.execute(sql) also works
    result = ShortenedUrl.find_by_sql(sql)
    result.map { |url| "#{url.short_url}: #{url.count} visits" }
  end
  

  # A more rails-y way of doing it, but complicated to get the right order/syntax. And the syntax seems
  # brittle/dependent on what version I'm using
  # https://github.com/rails/rails/issues/36022
  def popular_links3
    result = ShortenedUrl
      .joins(:tag_topics, :visits)
      .where('tag_topics.id = ?', id)
      .group('shortened_urls.short_url')
      .order(count: :desc)
      .limit(3)
      .count
      
    result.map { |url, count| "#{url}: #{count} visits" }
  end
  # count has to come last https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Calculations.html#method-i-count
  # the return value after using count is kind of strange. the key string depends on the grouping
  # the syntax for .order(:count) might fail in other versions
end

