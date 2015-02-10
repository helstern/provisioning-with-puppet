class PuppetStandaloneConfigurator

  attr_reader :provisioner_id

  attr_reader :guest_path

  # @param [String] provisioner_id
  # @param [String] guest_path
  # @param [Boolean] with_hiera
  # @param [Boolean] with_manifests
  def initialize (provisioner_id: '', guest_path: '', with_hiera: true, with_manifests: true)

    fail('provisioner_id must not be empty') if provisioner_id.empty?

    @provisioner_id = provisioner_id
    @guest_path     = guest_path

    @with_hiera = true
    @with_hiera = false if with_hiera.instance_of?(NilClass) || with_hiera.instance_of?(FalseClass)

    @with_manifests = true
    @with_manifests = false if with_manifests.instance_of?(NilClass) || with_manifests.instance_of?(FalseClass)

    @host_base_path = [File.dirname(__FILE__), '..'].join(File::SEPARATOR)
    @host_base_path = File.expand_path(@host_base_path)

  end

  # @param [String] path_name
  # @return [String]
  def host_path(path_name)

    case path_name
      when 'hiera'
        [@host_base_path, 'hiera'].join(File::SEPARATOR)
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

  # @param [String] path_name
  # @return [String]
  def guest_path(path_name)

    case path_name
      when 'hiera'
        [@guest_path, 'hiera'].join('/')
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

    if @with_hiera
      vm_config.synced_folder host_path('hiera'), guest_path('hiera')
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
      shell.path = [@host_base_path, 'shell', '0001.sync_packages.sh'].join(File::SEPARATOR)
    end

    vm_config.provision :shell do |shell|
      shell.path = [@host_base_path, 'shell', '0002.puppet_install.sh'].join(File::SEPARATOR)
      shell.args = ['--puppet_source /puppet']
    end

    nil
  end

  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def configure (vm_config, &block)

    options = []
    options << '--modulepath ' + [guest_path('puppet-modules'), '/etc/puppet/modules'].join(':')
    options << '--libdir ' + guest_path('puppet-libraries')

    options << '--hiera_config=' + guest_path('hiera') if @with_hiera
    options << '--manifestdir ' + guest_path('puppet-manifests') if @with_manifests

    if @with_manifests
      vm_config.provision :puppet, :id => @provisioner_id, :temp_dir => @guest_path, :manifest_file => 'bootstrap.pp', :options => options, &block
    else
      vm_config.provision :puppet, :id => @provisioner_id, :temp_dir => @guest_path, :options => options, &block
    end

    nil

  end

end