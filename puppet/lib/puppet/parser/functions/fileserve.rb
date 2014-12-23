require 'uri'
require 'puppet/file_serving/content'
require 'puppet/file_serving/metadata'

Puppet::Parser::Functions.autoloader.load(:file) unless Puppet::Parser::Functions.autoloader.loaded?(:file)

module Puppet::Parser::Functions
  newfunction(:fileserve,
    :type => :rvalue,
    :doc => <<ENDHEREDOC
  Loads the content of a file. Support puppet urls

  For example:
          fileserve('/etc/puppet/data/file.yaml')
          fileserve(puppet:///custom/name/myhash.yaml')
ENDHEREDOC
  ) do |args|

  unless args.length == 1
    raise Puppet::ParseError, ("fileserve(): wrong number of arguments (#{args.length}; must be 1)")
  end

  params = nil
  path = args[0]
  unless Puppet::Util.absolute_path?(path)
    uri = URI.parse(URI.escape(path))
    raise Puppet::ParseError, ("Cannot use relative URLs ''#{path}''") unless uri.absolute?
    raise Puppet::ParseError, ("Cannot use opaque URLs ''#{path}''") unless uri.hierarchical?
    raise Puppet::ParseError, ("Cannot use URLs of type ''#{uri.scheme}'' as source for fileserving") unless %w{puppet}.include?(uri.scheme)

    Puppet.info "loading parameters from #{path}"

    content = Puppet::FileServing::Content.indirection.find(path)
    return content.content
  else
    return function_file(path)
  end
  end
end