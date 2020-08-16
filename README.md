# URL Shortener

Created as part of the App Academy curriculum.

### Functionality

Simple Rails Application to create short URL links for various users' full URL submissions. A command line interface allows for viewing and creating submissions. No more than 3 submissions are  allowed in 1 minute. A non-premium user may only create up to 5 submissions. A `prune:prune_old_urls` rake task will remove old non-premium URLS. This is automated weekly with crontabs. The following models are used:

- ShortenedUrl
- TagTopic
- Tagging (association)
- User
- Visit
- Vote

### Thoughts

I encountered quite a few hurdles along the way. One was using a join table in Rails. I tried many versions of this line before figuring out the right syntax:

```ruby
ShortenedUrl.joins(:submitter).where('shortened_urls.created_at < ? AND users.premium IS FALSE', 3.days.ago).destroy_all
```

Some notes: Use the name of the association (`joins(:submitter)`) to let Rails figure out the right table and join condition, but inside the `where` clause, use the name of the table. Make sure to specify the table for all column names. Use `IS FALSE`, not `= FALSE`. `dependent: :destroy` is require for all `through` associations and `has_many` associations that share the association with other tables.

The custom validations were a little tricky to write:

```ruby
unless User.find(user_id).premium ||
			 self.class.where(user_id: user_id).count < 5
	errors[:base] << 'Non-premium user cannot submit more than 5 URLS.'
end
```

Validation will not fail unless `errors[:something]` is added.

The Vote class allows users to revote for the same URL, but before every `save`, first checks if a vote already exists for this user/url, and if it does, deletes it. This way users can change their vote:

```ruby
def save!
	self.class.where(user_id: user_id, url_id: url_id).delete_all
	super
end
```

`TagTopic#popular_links`, `ShortenedURL::top`, and `ShortenedURL::hot` use Ruby's sort rather than SQL ordering, which I know isn't ideal.

Getting crontab to run the rake task was a challenge. I was getting a 'Could not find a JavaScript runtime' error, and the main suggestion online is to add `therubyracer` to the `Gemfile`, but I couldn't get this installed because the required `libv8` gem could not build successfully. I found [this](https://github.com/rubyjs/libv8/issues/282) Github issue that said `mini_racer` 'uses up to date versions of v8 that have been compiled for Catalina,' and users of `therubyracer` encouraged to switch. `mini_racer` allowed the rake file to run succesfully through crontab.