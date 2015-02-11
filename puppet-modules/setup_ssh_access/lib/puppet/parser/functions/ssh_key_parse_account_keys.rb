require 'net/http'
require 'uri'

# load function download_key, extract_key_parts if it not yet loaded
Puppet::Parser::Functions.autoloader.load(:http_get) unless Puppet::Parser::Functions.autoloader.loaded?(:download_key)
Puppet::Parser::Functions.autoloader.load(:ssh_key_extract_parts) unless Puppet::Parser::Functions.autoloader.loaded?(:extract_key_parts)

module Puppet::Parser::Functions
  # extract open ssh public key parts
  newfunction(:ssh_key_parse_account_keys, :type => :rvalue, :doc => 'Parse a text containing user ssh-key lines') do |arg|

    if arg.kind_of?(Array).equal?(false) or arg.length != 1
      raise Puppet::ParseError, 'Insufficient number of arguments for ' + :download_key
    end

    if arg.at(0).kind_of?(String).equal?(false)
      raise Puppet::ParseError, 'Expecting a string, received ' + arg.at(0).class.to_s
    end

    authorized_keys = {}
    resource_name_format = 'account %s key number %s'
    resourceId = 0

    arg.at(0).split("\n").each do |line|

      next if line =~ /^\s*$/

      parts = line.split(' ')

      if parts.length == 2
        if parts.at(1) =~ /^https?:\/\//

          key = function_http_get([parts.at(1)])
          keyParts = function_ssh_key_extract_parts([key])

          resourceId = resourceId + 1
          resource_title = sprintf(resource_name_format, parts.at(0), resourceId.to_s)

          authorized_keys[resource_title] = {
              'user' => parts.at(0),
              'type' => keyParts['key_type'],
              'key'  => keyParts['pem_data'],
              'name' => keyParts['comment']
          }
        end
      else
        raise Puppet::ParseError, 'Only supporting account http://ssh.key.location'
      end
    end

    if resourceId < 1
      raise Puppet::ParseError, 'No ssh config found'
    end

    return authorized_keys
  end
end