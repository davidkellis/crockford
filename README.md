# crockford

This library implements Crockford's base 32 encoding as defined at https://www.crockford.com/base32.html.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crockford:
       github: davidkellis/crockford
   ```

2. Run `shards install`

## Usage

There are three methods that make up the API:

- Crockford.encode(number : Int, encoding : Encoding = Crockford::DEFAULT) : String

   Takes a non-negative integer and encodes it with Crockford's base-32 encoding.
   Returns a String representing the encoded value.

- Crockford.decode(str : String, encoding : Encoding = Crockford::DEFAULT) : Int64

   Decodes the given Crockford base-32 encoded string.
   Raises ArgumentError if the encoded string value does not represent a valid encoded value.
   Returns an Int64 representation of the encoded value.

- Crockford.decode?(str : String, encoding : Encoding = Crockford::DEFAULT) : Int64?

   Decodes the given Crockford base-32 encoded string.
   Returns an Int64 representation of the encoded value if the encoded string represents a valid encoded  value;
     otherwise, returns nil.


```crystal
require "crockford"

encoded_value = Crockford.encode(123)               # encoded_value = "3V"
decoded_value = Crockford.decode(encoded_value)     # decoded_value = 123

Crockford.encode(-5)                                # raises ArgumentError, "Unable to encode negative values."

Crockford.decode("invalid_value")                   # raises ArgumentError, "Unable to decode ordinal 95."

optional_val = Crockford.decode?("invalid_value")   # optional_val = nil
```

## Contributors

- [David Ellis](https://github.com/davidkellis) - creator and maintainer
