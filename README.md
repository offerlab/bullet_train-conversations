# Bullet Train Conversations

## Installation

Add the following to your `Gemfile`:

```ruby
source "https://YOUR_LICENSE_KEY@gem.fury.io/bullettrain" do
  gem "bullet_train-conversations"
end
```

And run the following on your shell:

```bash
$ bundle install
$ rake bt:link
$ rake bullet_train:conversations:install
$ rails restart
```

## Example Usage

```bash
rails g model Project team:references name:string
bin/super-scaffold crud Project Team name:text_field
bin/super-scaffold conversations Project Team
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
