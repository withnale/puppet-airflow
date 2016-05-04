require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'airflow')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib','--version','4.9.0')
      on host, puppet('module','install','stankevich-python','--version','1.12.0')
      on host, puppet('module','install','camptocamp-systemd','--version','0.2.2')
      on host, puppet('module','install','steakknife-runit','--version','0.1.1')
      on host, puppet('module','install','puppetlabs-postgresql')
      on host, puppet('module','install','puppetlabs-vcsrepo')
    end
  end
end
