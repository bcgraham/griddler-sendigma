# Sendigma

Sendgrid adapter for [Griddler](https://github.com/thoughtbot/griddler)[.](https://youtu.be/cWrnjDXx5x4?start=60)

In what is passed to Griddler, Sendigma includes an extra field called `extras`, which contains the Parse fields not used by Griddler:

    :dkim
    :sender_ip
    :envelope
    :charsets
    :SPF
    :spam_score
    :spam_report

Hopefully, [Brad Pauly](https://github.com/bradpauly/griddler/tree/add-extras-param)'s [pull request](https://github.com/thoughtbot/griddler/pull/233) gets merged, and this can use the mainline release of Griddler.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'griddler', github: 'bradpauly/griddler', branch: 'add-extras-param'
gem 'sendigma', git: 'https://github.com/briancgraham/griddler-sendigma'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install griddler-sendigma

## Usage

Set the adapter to `:sendigma`:
```ruby
Griddler.configure do |config|
  config.email_service = :sendigma
end
```

## License

Borrowed much from [Griddler-Sendgrid](https://github.com/thoughtbot/griddler-sendgrid)

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

