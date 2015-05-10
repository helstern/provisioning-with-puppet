class SyncedFolderHiera

  attr_reader :host_path

  attr_reader :hiera_datadir_guest_path

  attr_reader :hierarchy_level

  def initialize(host_path, hiera_datadir_guest_path, hierarchy_level)
    @host_path = host_path
    @hiera_datadir_guest_path = hiera_datadir_guest_path
    @hierarchy_level = hierarchy_level
  end

  # Synchronizes any folders from the host machine which are required
  #
  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def sync (vm_config)
    vm_config.synced_folder @host_path, guest_path
  end

  def guest_path
    [@hiera_datadir_guest_path, @hierarchy_level].join('/')
  end

  def to_s
    "(host path:#@host_path, guest_path:#{guest_path})"  # string formatting of the object.
  end

end
