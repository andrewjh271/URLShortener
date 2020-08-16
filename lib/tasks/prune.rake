namespace :prune do
  desc 'Prune old urls and associations from ShortenedUrl table.'
  task prune_old_urls: :environment do
    puts 'Pruning old urls...'
    ShortenedUrl.prune
  end
end