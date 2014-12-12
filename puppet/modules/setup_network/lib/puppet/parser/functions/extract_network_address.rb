module Puppet::Parser::Functions
  # this function will calculate the network address from a ip address and a netmask
  # arg[0] is the ip address in dot-decimal format
  # arg[1] is the netmask in dot-decimal format
  #
  # @return [String] the network address in dot.decimal format
  newfunction(:extract_network_address, :type => :rvalue) do |arg|

    if arg.kind_of?(Array).equal?(false) or arg.length != 2
      raise Puppet::ParseError, "Insufficient number of arguments for extract_network_address"
    end

    #regex to validate an ip in dot_decimal notation
    ipRegex = %r{
      (?:25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])
      (?:[.](?:25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])){3}
    }x

    #type convert just to get code completion
    arg = Array(arg)

    if ipRegex.match(arg.at(0)).nil?
      raise Puppet::ParseError, "extract_network_address expects the first argument to be an ip in dot decimal notation"
    end

    netmaskOctets = arg.at(1).to_s.split(".")
    if (netmaskOctets.size != 4)
      raise Puppet::ParseError, "extract_network_address expects the second argument to be a netmask in dot decimal"
    end

    ipOctets = arg.at(0).to_s.split(".")

    networkAddress = (ipOctets.at(0).to_s.to_i & netmaskOctets.at(0).to_s.to_i).to_s
    for i in 1..3
      networkAddress << "."
      block = ipOctets.at(i).to_s.to_i & netmaskOctets.at(i).to_s.to_i
      networkAddress << block.to_s
    end

    return networkAddress;

    #netmaskOctets.each_with_index { |index, octet|
    #    octet.to_s.to_i(10)
    #}
    #
    #if ipRegex.match(args(1)).nil?
    #  raise Puppet::ParseError, "extract_network_address expects the second argument to be a netmask in dot decimal"
    #end
  end
end