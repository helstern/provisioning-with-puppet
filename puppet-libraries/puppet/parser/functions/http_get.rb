require 'net/http'
require 'uri'

module Puppet::Parser::Functions
  # extract open ssh public key parts
  newfunction(:http_get, :type => :rvalue, :doc => 'retrieve content from a http server') do |arg|

    if arg.kind_of?(Array).equal?(false) or arg.length != 1
      raise Puppet::ParseError, 'Insufficient number of arguments for ' + :download_key
    end

    if arg.at(0).kind_of?(String).equal?(false)
      raise Puppet::ParseError, 'Expecting a string, received ' + arg.at(0).class.to_s
    end

    originalUrl = URI.parse(URI.encode(arg.at(0)))

    originalRequest = Net::HTTP::Get.new(originalUrl.request_uri)

    http = Net::HTTP.new(originalUrl.host, originalUrl.port)
    if arg.at(0) =~ /^https/
      http.use_ssl = true
    end

    response = http.request(originalRequest)

    redirectsToFollow = 10
    while redirectsToFollow > 0 and response.kind_of?(Net::HTTPRedirection)
      redirectsToFollow -= 1

      url = URI.parse(URI.encode(response['location']))
      http = Net::HTTP.new(url.host, url.port)
      if response['location'] =~ /^https/
        http.use_ssl = true
      end

      request = Net::HTTP::Get.new(url.request_uri)
      response = http.request(request)
    end

    if response.kind_of?(Net::HTTPSuccess)
      return response.body
    end

    raise Puppet::ParseError, 'Could not fetch the key, returned response type is ' + response.class.to_s
  end
end