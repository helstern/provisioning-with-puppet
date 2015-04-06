class PuppetStandaloneConfigurator

  attr_reader :provisioner_id

  attr_reader :guest_path


  # @param [Hash] opts
  def initialize (opts = {})
    opts = { :provisioner_id => '', :guest_path => '', :with_hiera => false, :with_manifests => true }.merge(opts)
    fail('provisioner_id must not be empty') if opts.fetch('provisioner_id').empty?

    @provisioner_id = opts.fetch('provisioner_id')
    @guest_path     = opts.fetch('guest_path')

    @with_hiera = nil
    @with_hiera = opts.fetch('with_hiera') unless opts.fetch('with_hiera').nil?

    @with_manifests = false
    @with_manifests = true if opts.fetch('with_manifests') == true

    @host_base_path = [File.dirname(__FILE__), '..'].join(File::SEPARATOR)
    @host_base_path = File.expand_path(@host_base_path)

  end

  # @param [String] path_name
  # @return [String]
  def host_path(path_name)

    case path_name
      when 'hiera-defaults'
        [@host_base_path, 'puppet-hiera', 'defaults'].join(File::SEPARATOR)
      when 'hiera.yaml'
        [@host_base_path, 'puppet-hiera', 'hiera.yaml'].join(File::SEPARATOR)
      when 'puppet-hiera'
        [@host_base_path, 'puppet-hiera'].join(File::SEPARATOR)
      when 'puppet-manifests'
        [@host_base_path, 'puppet-manifests'].join(File::SEPARATOR)
      when 'puppet-librarian'
        [@host_base_path, 'puppet-librarian'].join(File::SEPARATOR)
      when 'puppet-libraries'
        [@host_base_path, 'puppet-libraries'].join(File::SEPARATOR)
      when 'puppet-modules'
        [@host_base_path, 'puppet-modules'].join(File::SEPARATOR)
      else
        fail('unknown host path ' + path_name)
    end

  end

  def hiera_guest_path (path_name)
    [@guest_path, 'hiera', path_name.to_s].join('/')
  end

  # @param [String] path_name
  # @return [String]
  def guest_path(path_name)

    case path_name
      when 'hiera-defaults'
        [@guest_path, 'hiera', 'defaults'].join('/')
      when 'hiera.yaml'
        [@guest_path, 'puppet-hiera', 'hiera.yaml'].join('/')
      when 'puppet-hiera'
        [@guest_path, 'puppet-hiera'].join('/')
      when 'puppet-manifests'
        [@guest_path, 'puppet-manifests'].join('/')
      when 'puppet-librarian'
        [@guest_path, 'puppet-librarian'].join('/')
      when 'puppet-libraries'
        [@guest_path, 'puppet-libraries'].join('/')
      when 'puppet-modules'
        [@guest_path, 'puppet-modules'].join('/')
      else
        fail('unknown guest path ' + path_name)
    end

  end

  # Synchronizes any folders from the host machine which are required
  #
  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def sync_folders (vm_config)

    unless @with_hiera.nil?
      vm_config.synced_folder host_path('puppet-hiera'), guest_path('puppet-hiera')
      vm_config.synced_folder host_path('hiera-defaults'), guest_path('hiera-defaults')
      @with_hiera.each do |hiera_node|
        vm_config.synced_folder hiera_node.fetch(:host_path), hiera_guest_path(hiera_node.fetch(:name))
      end
    end

    if @with_manifests
      vm_config.synced_folder host_path('puppet-manifests'), guest_path('puppet-manifests')
    end

    vm_config.synced_folder host_path('puppet-librarian'), guest_path('puppet-librarian')
    vm_config.synced_folder host_path('puppet-libraries'), guest_path('puppet-libraries')
    vm_config.synced_folder host_path('puppet-modules'), guest_path('puppet-modules')

  end

  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def install (vm_config)

    vm_config.provision :shell do |shell|
      shell.path = [@host_base_path, 'shell', '0001.pre_requisites.sh'].join(File::SEPARATOR)
    end

    vm_config.provision :shell do |shell|
      shell.path = [@host_base_path, 'shell', '0002.puppet_install.sh'].join(File::SEPARATOR)
    end

    vm_config.provision :shell do |shell|
      shell.path = [@host_base_path, 'shell', '0003.puppet_tools.sh'].join(File::SEPARATOR)
    end

    nil
  end

  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def configure (vm_config, &block)

    options = []
    options << '--modulepath ' + [guest_path('puppet-modules'), '/etc/puppet/modules'].join(':')
    options << '--libdir ' + guest_path('puppet-libraries')

    options << '--hiera_config ' + guest_path('hiera.yaml') unless @with_hiera.nil?
    options << '--manifestdir ' + guest_path('puppet-manifests') if @with_manifests

    if @with_manifests
      vm_config.provision @provisioner_id.to_sym, :temp_dir => @guest_path, :manifest_file => 'bootstrap.pp', :options => options, &block
    else
      vm_config.provision @provisioner_id.to_sym, :temp_dir => @guest_path, :options => options, &block
    end

    nil

  end

end
