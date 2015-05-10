class SyncedFolderNormal

  attr_reader :host_path

  attr_reader :guest_path

  def initialize(host_path, guest_path)
    @host_path = host_path
    @guest_path = guest_path
  end

  # Synchronizes any folders from the host machine which are required
  #
  # @param [::VagrantPlugins::Kernel_V2::VMConfig] vm_config
  def sync (vm_config)
    vm_config.synced_folder @host_path, @guest_path
  end

  def to_s
    "(host path:#@host_path, guest path:#@guest_path)"  # string formatting of the object.
  end

end
