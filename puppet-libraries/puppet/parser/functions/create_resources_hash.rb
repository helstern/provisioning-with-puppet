Puppet::Parser::Functions.autoloader.load(:file) unless Puppet::Parser::Functions.autoloader.loaded?(:file)

module Puppet::Parser::Functions
  newfunction(:create_resources_hash,
              :type => :rvalue,
              :doc => <<ENDHEREDOC
  transforms an array of namevars into unique resource hashes that can be used with create_resources

  see https://docs.puppetlabs.com/puppet/latest/reference/lang_resources.html#namenamevar
  see https://docs.puppetlabs.com/references/latest/function.html#createresources

  For example:
          create_resources_hash('mymodule::myclass', ['package1', 'package2'], 'name' )
          create_resources_hash('mymodule::myclass', ['package1', 'package2'])
          returns:
          {
            'mymodule::myclass::package1' => {'name' => 'package1'},
            'mymodule::myclass::package2' => {'name' => 'package2'},
          }
ENDHEREDOC
  ) do |args|

    unless args.length > 1
      raise Puppet::ParseError, ("array2hash(): wrong number of arguments (#{args.length}; must be 2 or 3")
    end

    namespace = args[0]
    if namespace.kind_of?(String).equal?(false)
      raise Puppet::ParseError, 'first parameter must be a string'
    end

    list = args[1]
    if list.kind_of?(Array).equal?(false)
      raise Puppet::ParseError, 'first parameter must be a string'
    end

    if list.length == 0
      return {}
    end

    if args.length == 2
      namevar_attr = 'name'
    else
      namevar_attr = args[2]
    end

    if namevar_attr.kind_of?(String).equal?(false)
      raise Puppet::ParseError, "namevar must be a string: #{namevar_attr}"
    end

    resource_hash = {}
    list.each do |namevar|
      title = "#{namespace}::#{namevar}"
      resource_hash[title] = {
          namevar_attr => namevar
      }
    end

    return resource_hash

  end
end