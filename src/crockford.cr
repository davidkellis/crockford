# this implements Crockford encoding, as defined at https://www.crockford.com/base32.html
module Crockford
  extend self

  class Encoding
    property alphabet : Array(UInt8)         # Array(UInt8) serves as a mapping from symbol value (0-31) to encoded ASCII ordinal (e.g. 15 -> 'F'.ord, 31 -> 'Z'.ord)
    property decode_map : Hash(UInt8, UInt8) # Hash(UInt8, UInt8) serves as a mapping from ASCII ordinal to decoded symbol value (e.g. 'F'.ord -> 15, 'Z'.ord -> 31)

    def initialize(@alphabet, @decode_map)
    end

    # encode UInt8 value in the range 0-31 into an ASCII character represented as a UInt8
    def encode(val : UInt8) : UInt8
      @alphabet[val]
    end
  
    # decode ASCII character represented as a UInt8 into a UInt value in the range 0-31
    def decode(ascii_ord : UInt8) : UInt8
      decode_map[ascii_ord]? || raise ArgumentError.new("Unable to decode ordinal #{ascii_ord}.")
    end
  end

  CROCKFORD_ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ".bytes
  DEFAULT            = Encoding.new(CROCKFORD_ALPHABET, Hash.zip(CROCKFORD_ALPHABET, (0_u8..31_u8).to_a).merge({'I'.ord.to_u8 => 1.to_u8, 'L'.ord.to_u8 => 1.to_u8, 'O'.ord.to_u8 => 0.to_u8}))

  # Takes a non-negative integer and encodes it with Crockford's base-32 encoding.
  # Returns a String representing the encoded value.
  def encode(number : Int, encoding : Encoding = DEFAULT) : String
    raise ArgumentError.new("Unable to encode negative values.") if number < 0
    return "0" if number == 0

    byte_count = count_base32_digits_needed_for(number)
    String.new(byte_count) do |buffer_pointer|
      byte_ptr = buffer_pointer + byte_count - 1          # skip to the last byte of the string buffer
      each_base32_digit(number) do |base32_digit|
        byte_ptr.value = encoding.encode(base32_digit)    # fill in the string buffer's bytes in order of least significant byte to most significant byte (right to left)
        byte_ptr -= 1                                     # jump to the previous byte in the string buffer
      end
      {byte_count, byte_count}
    end
  end

  # Decodes the given Crockford base-32 encoded string.
  # Raises ArgumentError if the encoded string value does not represent a valid encoded value.
  # Returns an Int64 representation of the encoded value.
  def decode(str : String, encoding : Encoding = DEFAULT) : Int64
    clean(str).each_byte.map { |ascii_ord| encoding.decode(ascii_ord) }.reduce(0_i64) { |result, val| (result << 5) + val }
  end

  # Decodes the given Crockford base-32 encoded string.
  # Returns an Int64 representation of the encoded value if the encoded string represents a valid encoded value;
  #   otherwise, returns nil.
  def decode?(str : String, encoding : Encoding = DEFAULT) : Int64?
    decode(str, encoding)
  rescue ArgumentError
    nil
  end

  private def clean(str : String) : String
    str.gsub('-', "").upcase
  end

  private def each_base32_digit(num : Int)
    while num > 0
      digit : UInt8 = 0b11111_u8 & num
      num = num >> 5 # number / 32
      yield digit
    end
  end

  private def count_base32_digits_needed_for(num : Int) : Int32
    digits = 0
    while num > 0
      digits += 1
      num = num >> 5
    end
    digits
  end
end
