module Puppet::Parser::Functions
  # extract open ssh public key parts
  newfunction(:ssh_key_extract_parts, :type => :rvalue, :doc => 'extracts key type, pem data and comment components of a public ssh key') do |arg|

    if arg.kind_of?(Array).equal?(false) or arg.length != 1
      raise Puppet::ParseError, 'Insufficient number of arguments for ' + :extract_key_parts
    end

    if arg.at(0).kind_of?(String).equal?(false)
      raise Puppet::ParseError, 'Expecting a string, received ' + arg.at(0).class.to_s
    end

    fields = arg.at(0).split(' ')

    if fields.length < 3
      raise Puppet::ParseError, "incorrect key type"
    end

    if fields.at(0) !~ /^(ssh-rsa|ssh-dsa)$/ or fields.at(1).empty? or fields.at(2).empty?
      raise Puppet::ParseError, "Missing key fields"
    end

    parts = {
      'key_type' => fields.at(0),
      'pem_data' => fields.at(1),
      'comment' => fields.at(2)
    }

    return parts
  end
end