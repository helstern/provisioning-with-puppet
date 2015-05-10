class PuppetStandaloneConfigurator

  attr_reader :provisioner_id

  attr_reader :guest_path

  # @param [Hash] opts
  def initialize (opts = {})
    opts = {
        :provisioner_id => '',
        :guest_path => '',
        :puppet  => {
            :use_default_manifests => true,
            :module_extra_dirs => []
        }
    }.merge(opts)

    fail('provisioner_id must not be empty') if opts.fetch(:provisioner_id).empty?

    @provisioner_id = opts.fetch(:provisioner_id)
    @guest_path     = opts.fetch(:guest_path)

    @with_hiera = nil
    @with_hiera = opts.fetch(:with_hiera) unless opts.fetch(:with_hiera).nil?

    @use_default_manifests = false
    @use_default_manifests = true if opts.fetch(:puppet).fetch(:use_default_manifests) == true

    @module_extra_dirs = []
    @module_extra_dirs = opts.fetch(:puppet).fetch(:module_extra_dirs) unless opts.fetch(:puppet).nil? || opts.fetch(:puppet).fetch(:module_extra_dirs).nil?

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

  # @return [Array[SyncedFolderNormal]]
  def list_synced_folders
    list = []

    folder_names_list = %w(puppet-librarian puppet-libraries puppet-modules)
    hiera_folder_names_list = %w(puppet-hiera hiera-defaults)

    unless @with_hiera.nil?
      folder_names_list.concat(hiera_folder_names_list)
    end

    # sync all the folders
    folder_names_list.each do |name|
      host_path = host_path(name)
      guest_path = guest_path(name)

      synced_folder = SyncedFolderNormal.new(host_path, guest_path)
      list.push(synced_folder)
    end

    # custom hiera folders which should be mounted after all the others
    unless @with_hiera.nil?
      hiera_path = guest_path('puppet-hiera')
      @with_hiera.each do |hiera_node|
        host_path = hiera_node.fetch(:host_path)
        hierarchy_name = hiera_node.fetch(:name)

        fail('hiera defaults level can not be overridden') if  'defaults'.eql?(hierarchy_name)

        synced_folder = SyncedFolderHiera.new(host_path, hiera_path, hierarchy_name)
        list.push(synced_folder)
      end
    end

    list
  end

  # Synchronizes any folders from the host machine which are required
  #
  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def sync_folders (vm_config)

    synced_folders = list_synced_folders
    synced_folders.each do |synced_folder|
      synced_folder.sync(vm_config)
    end

  end

  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def install (vm_config)

    install_scripts = %w(0001.pre_requisites.sh 0002.puppet_install.sh 0003.puppet_tools.sh)
    install_scripts.each do |script|
      vm_config.provision :shell do |shell|
        path = [@host_base_path, 'shell', script].join(File::SEPARATOR)
        shell.path = path
      end
    end

    nil

  end

  def list_puppet_options

    options = []
    module_dirs = [guest_path('puppet-modules'), '/etc/puppet/modules']
    options << '--modulepath ' + @module_extra_dirs.concat(module_dirs).join(':')
    options << '--libdir ' + guest_path('puppet-libraries')

    options << '--hiera_config ' + guest_path('hiera.yaml') unless @with_hiera.nil?
    options << '--manifestdir ' + guest_path('puppet-manifests') if @use_default_manifests

    options

  end

  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def configure (vm_config, &block)

    if @use_default_manifests
      vm_config.provision(
        @provisioner_id.to_sym,
        :temp_dir => @guest_path,
        :manifest_file => 'bootstrap.pp',
        :options => list_puppet_options,
        &block
      )
    else
      vm_config.provision(@provisioner_id.to_sym, :temp_dir => @guest_path, :options => list_puppet_options, &block)
    end

    nil

  end

end
