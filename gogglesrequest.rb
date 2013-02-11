require 'net/http'
require 'uri'
require 'base64'
require './gogglesparser.rb'

# This class is used to make image recognition
# request to Google's Goggles
class GogglesRequest

  # Request definitions
  HTTP_OK = '200'
  GOGGLES_REQUEST_URL = 'https://www.google.com/goggles/container_proto?cssid='
  GOGGLES_REQUEST_CONTENT_TYPE = 'application/x-protobuffer'
  GOGGLES_REQUEST_PRAGMA = 'no-cache'
  TRAILING_BYTES = [ 0x18, 0x4B, 0x20, 0x01, 0x30, 0x00, 
                     0x92, 0xEC, 0xF4, 0x3B, 0x09, 0x18, 
                     0x00, 0x38, 0xC6, 0x97, 0xDC, 0xDF,
                     0xF7, 0x25, 0x22, 0x00 ].pack 'c*'

  # Sends a image recognition request to Goggles
  # 'image' is the binary representation of the image file
  def self.make_request image
    uri = URI(GOGGLES_REQUEST_URL)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |https|
      request = Net::HTTP::Post.new uri.request_uri
      request['Content-Type'] = GOGGLES_REQUEST_CONTENT_TYPE
      request['Pragma'] = GOGGLES_REQUEST_PRAGMA
      request.body = build_post_data image
      response = https.request request
      https.finish
      response.body if response.code == HTTP_OK
    end if image
  end

  # Reads a binary file
  def self.read_file filename
    File.open(filename, 'rb').read if filename && File.exists?(filename)
  end

  # Decodes a Base64 encoded string
  def self.decode_base64 encoded
    Base64.decode64 encoded if encoded
  end

  # Makes an image recognition request to Goggles and returns
  # the parsed response
  # FLAGS:
  #   :file => if true the image is read from file and
  #     'image' treated as a filename
  #   :decode => if true the image will be decoded
  def self.lookup_image image, flags = {}
    image = read_file image if flags[:file]
    image = decode_base64 image if flags[:decode]
    if response = make_request(image)
      GogglesParser.parse_response response
    end
  end

  # Builds the post body to send to Goggles
  def self.build_post_data image
    x = image.length
    s = ''
    [32, 14, 10, 0].each do |y|
      s += [10].pack('c') + GogglesParser.int_to_varint_32(x + y).pack('c*')
    end
    s += image + TRAILING_BYTES
  end
end
