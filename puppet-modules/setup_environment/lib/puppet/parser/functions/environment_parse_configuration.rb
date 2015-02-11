
module Puppet::Parser::Functions
  # extract open ssh public key parts
  newfunction(:environment_parse_configuration, :type => :rvalue, :doc => 'Parse a text containing user environment configuration') do |arg|

    if arg.kind_of?(Array).equal?(false) or arg.length != 1
      raise Puppet::ParseError, 'Insufficient number of arguments for ' + :environment_parse_configuration
    end

    if arg.at(0).kind_of?(String).equal?(false)
      raise Puppet::ParseError, 'Expecting a string, received ' + arg.at(0).class.to_s
    end

    environment = {}
    resource_name_format = 'environment for %s key number %s'
    resourceId = 0

    arg.at(0).split("\n").each do |line|

      next if line =~ /^\s*$/

      parts = line.split(' ')

      if parts.length == 2

        #todo validate each part

        resourceId = resourceId + 1
        resource_title = sprintf(resource_name_format, parts.at(0), resourceId.to_s)
        environment[resource_title] = {
            'user' => parts.at(0),
            'vcsSource' => parts.at(1),
        }
      else
        raise Puppet::ParseError, 'Only supporting user git.repo'
      end
    end

    if resourceId < 1
      raise Puppet::ParseError, 'No user environment config found'
    end

    return environment
  end
end