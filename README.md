# Snowly - Snowplow Request Validator

Debug your Snowplow implementation locally, without resorting to Snowplow's ETL tasks. It's like Facebook's URL Linter, but for Snowplow.

Snowly is a minimal [Collector](https://github.com/snowplow/snowplow/wiki/Setting-up-a-collector) implementation intended to run on your  development environment. It comes with a comprehensive validation engine, that will point out any schema requirement violations. You can easily validate your event requests before having to emmit them to a cloudfront, closure or scala collector.

### Motivation

Snowplow has an excellent toolset, but the first implementation stages can be hard. To run Snowplow properly you have to set up a lot of external dependencies like AWS permissions, Cloudfront distributions and EMR jobs. If you're tweaking the snowplow model to fit your needs or using trackers that don't enforce every requirement, you'll find yourself waiting for the ETL jobs to run in order to validate every implementation changes.

### Who will get the most from Snowly

- Teams that need to extend the snowplow model with custom contexts or unstructured events.
- Applications that are constantly evolving their schemas and rules.
- Developers trying out Snowplow before commiting to it.

### Features

With Snowly you can use [Json Schemas](http://spacetelescope.github.io/understanding-json-schema/) to define more expressive event requirements. Aside from assuring that you're fully compatible with the snowplow protocol, you can go even further and extend it with a set of more specific rules.

Use cases:

- Validate custom contexts or unstructured event types and required fields.
- Restrict values for any field, like using a custom dictionary for the structured event action field.
- Define requirements based on the content of another field: If __event action__ is 'viewed_product', __event property__ is required.

## Installation

```bash
gem install snowly
```
That will copy a `snowly` executable to your system.

### Development Iglu Resolver Path

If you still don't know anything about [Snowplow's Iglu Resolvers](https://github.com/snowplow/iglu), don't worry. It's pretty straightforward.
Snowly must be able to find your custom context and unstructured event schemas, so you have to set up a local path to store them. You can also choose to use an [external resolver](https://github.com/snowplow/iglu/wiki/Static-repo-setup) pointing to an URL.

For a local setup, store your schemas under any path accessible by your user(eg: ~/schemas). The only catch is that you must comply with snowplow's naming conventions for your json schemas. Snowplow References:[[1]](https://github.com/snowplow/snowplow/wiki/snowplow-tracker-protocol#custom-contexts),[[2]](https://github.com/snowplow/snowplow/wiki/snowplow-tracker-protocol#310-custom-unstructured-event-tracking)

You must export an environment variable to make Snowly aware of that path. Add it to your .bash_profile or equivalent.
```bash
# A local path is the recommended approach, as its easier to evolve your schemas
# without the hassle of setting up an actual resolver.
export DEVELOPMENT_IGLU_RESOLVER_PATH=~/schema

# or host on a Static Website on Amazon Web Services, for instance.
export DEVELOPMENT_IGLU_RESOLVER_PATH=http://my_resolver_bucket.s3-website-us-east-1.amazonaws.com
```

Example:
```bash
# create a user context
mkdir -p ~/schemas/com.my_company/hero_user/jsonschema
touch ~/schemas/com.my_company/hero_user/jsonschema/1-0-0

# create a viewed product unstructured event
mkdir -p ~/schemas/com.my_company/viewed_product/jsonschema
touch ~/schemas/com.my_company/viewed_product/jsonschema/1-0-0
```

`1-0-0` is the actual json schema file. You will find examples just ahead.

## Usage

Just use `snowly` to start and `snowly -K` to stop. Where allowed, a browser window will open showing the collector's address.

Other options:

    -K, --kill               kill the running process and exit
    -S, --status             display the current running PID and URL then quit
    -s, --server SERVER      serve using SERVER (thin/mongrel/webrick)
    -o, --host HOST          listen on HOST (default: 0.0.0.0)
    -p, --port PORT          use PORT (default: 5678)
    -x, --no-proxy           ignore env proxy settings (e.g. http_proxy)
    -e, --env ENVIRONMENT    use ENVIRONMENT for defaults (default: development)
    -F, --foreground         don't daemonize, run in the foreground
    -L, --no-launch          don't launch the browser
    -d, --debug              raise the log level to :debug (default: :info)
        --app-dir APP_DIR    set the app dir where files are stored (default: ~/.vegas/collector)/)
    -P, --pid-file PID_FILE  set the path to the pid file (default: app_dir/collector.pid)
        --log-file LOG_FILE  set the path to the log file (default: app_dir/collector.log)
        --url-file URL_FILE  set the path to the URL file (default: app_dir/collector.url)

## JSON Schemas

JSON Schema is a powerful tool for validating the structure of JSON data. I recommend reading this excellent [Guide](http://spacetelescope.github.io/understanding-json-schema/) from Michael Droettboom to understand all of its capabilities, but you can start with the examples bellow.

Example:

A user context. Well... Not just any user can get there.

__Note that this is not valid json because of the comments.__
```ruby
# ~/schemas/com.my_company/hero_user/jsonschema/1-0-0
{
  # Your schema will also be checked against the Snowplow Self-Desc Schema requirements.
  "$schema": "http://iglucentral.com/schemas/com.snowplowanalytics.self-desc/schema/jsonschema/1-0-0#",
  "id": "com.my_company/hero_user/jsonschema/1-0-0", # Give your schema an id for better validation output
  "description": "My first Hero Context",
  "self": {
    "vendor": "com.my_company",
    "name": "hero_user",
    "format": "jsonschema",
    "version": "1-0-0"
  },

  "type": "object",
  "properties": {
    "name": {
      "type": "string",
      "maxLength": 100 # The hero's name can't be larger than 100 chars
    },
    "special_powers": {
      "type": "array",
      "minItems": 2, # This is not just any hero. He must have at least two special powers.
      "uniqueItems": true
    },
    "age": {
      "type": "integer", # Strings are not allowed.
      "minimum": 15, # The Powerpuff Girls aren't allowed
      "maximum": 100 # Wolverine is out
    },
    "cape_color": {
      "type": "string",
      "enum": ["red", "blue", "black"] # Xmen Vision is not welcome
    },
    "is_avenger": {
      "type": "boolean"
    },
    "rating": {
      "type": "number" # Allows for float values
    },
    "address": { # cascading objects with their own validation rules.
      "type": "object",
      "properties": {
        "street_name": {
          "type": "string"
        },
        "number": {
          "type": "integer"
        }
      }
    }
  },
  "required": ["name", "age"], # Name and Age must always be present
  "custom_dependencies": {
    "cape_color": { "name": "superman" } # If the hero's #name is 'superman', #cape_color has to be present.
  },
  "additionalProperties": false # No other unspecified attributes are allowed.
}
```

### Extending Snowplow's Protocol

Although the Snowplow's protocol isn't originally defined in a JSON schema, it doesn't hurt to do so and take advantage of all its perks. It's also here for the sake of consistency, right?

By expressing the protocol in a JSON schema you can extend it to fit your particular needs and enforce domain rules that otherwise wouldn't be available. [Take a look](https://github.com/angelim/snowly/blob/master/lib/schemas/snowplow_protocol.json) at the default schema, derived from the rules specified on the [canonical model](https://github.com/snowplow/snowplow/wiki/canonical-event-model).

Whenever possible, Snowly will output column names mapped from query string parameters. When two parameters can map to the same content(eg. regular and base64 versions), a common intuitive name is used(eg. contexts and unstruct_event).

You can override the protocol schema by placing it anywhere inside your Local Resolver Path. As of now, the whole file has to be replaced:

__It's important to name the file as `snowplow_protocol.json`.__

One example of useful extensions.
```ruby
  ...
  "se_action": {
    "type": "string",
    "enum": ["product_view", "add_to_cart", "product_zoom"] # Only these values are allowed for an structured event action.
  }

  "custom_dependencies": {
      "true_tstamp": {"platform": "mob"} # You must submit the true timestamp when the platform is set to "mob".
  {
  ...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/angelim/snowly.

