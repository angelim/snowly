# Snowly - Snowplow Request Validator

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://github.com/angelim/snowly-heroku)

Debug your Snowplow implementation locally, without resorting to Snowplow's ETL tasks. It's like Facebook's URL Linter, but for Snowplow.

Snowly is a minimal [Collector](https://github.com/snowplow/snowplow/wiki/Setting-up-a-collector) implementation intended to run on your  development environment. It comes with a comprehensive validation engine, that will point out any schema requirement violations. You can easily validate your event requests before having to emit them to a cloudfront, closure or scala collector.

### Motivation

Snowplow has an excellent toolset, but the first implementation stages can be hard. To run Snowplow properly you have to set up a lot of external dependencies like AWS permissions, Cloudfront distributions and EMR jobs. If you're tweaking the snowplow model to fit your needs or using trackers that don't enforce every requirement, you'll find yourself waiting for the ETL jobs to run in order to validate every implementation change.

### Who will get the most from Snowly

- Teams that need to extend the snowplow model with custom contexts or unstructured events.
- Applications that are constantly evolving their schemas and rules.
- Developers trying out Snowplow before commiting to it.

### Features

With Snowly you can use [Json Schemas](http://spacetelescope.github.io/understanding-json-schema/) to define more expressive event requirements. Aside from assuring that you're fully compatible with the snowplow protocol, you can go even further and extend it with a set of more specific rules. Snowly emulates both cloudfront and closure collectors and will handle its differences automatically.

Use cases:

- Validate custom contexts or unstructured event types and required fields.
- Restrict values for any field, like using a custom dictionary for the structured event action field.
- Define requirements based on the content of another field: If __event action__ is 'viewed_product', then __event property__ is required.

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

Just use `snowly` to start and `snowly -K` to stop. Where allowed, a browser window will open showing the collector's address. Use `snowly --help` for other options.

### Output

When Snowly finds something wrong, it renders a parsed array of requests along with its errors.

When everything is ok, Snowly delivers the default Snowplow pixel, unless you're using the debug mode.

If you can't investigate the request's response, you can start Snowly in the foreground and in __Debug Mode__ to output the response to __STDOUT__.
`snowly -d -F`

Example: 
`http://0.0.0.0:5678/i?&e=pv&page=Root%20README&url=http%3A%2F%2Fgithub.com%2Fsnowplow%2Fsnowplow&aid=snowplow&p=i&tv=no-js-0.1.0&eid=ev-id-1`
```json
[
  {
    "event_id": "ev-id-1",
    "errors": [
      "The property '#/platform' value \"i\" did not match one of the following values: web, mob, pc, srv, tv, cnsl, iot in schema snowplow_protocol.json",
      "The property '#/' did not contain a required property of 'useragent' in schema snowplow_protocol.json"
    ],
    "content": {
      "event": "pv",
      "page_title": "Root README",
      "page_url": "http://github.com/snowplow/snowplow",
      "app_id": "snowplow",
      "platform": "i",
      "v_tracker": "no-js-0.1.0",
      "event_id": "ev-id-1"
    }
  }
]
```

If you're using the closure collector and can't see your requests firing up right away, try [manually flushing](https://github.com/snowplow/snowplow/wiki/Ruby-Tracker#54-manual-flushing) or change your emitter's buffer_size(number of events before flusing) to a lower value.

In debug mode Snowly always renders the parsed contents of your requests. If you're using the javascript tracker, use the __post__ option to be able to read the response in your browser inspector. The js tracker implementation for __get__ requests works by changing an image src, so the inspector hides the response.

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
      "enum": ["red", "blue", "black"] # Vision is not welcome
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

Although the Snowplow's protocol isn't originally defined as a JSON schema, it doesn't hurt to do so and take advantage of all its perks. It's also here for the sake of consistency, right?

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

