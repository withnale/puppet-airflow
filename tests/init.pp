# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#

class { 'postgresql::server':
  listen_addresses           => '*',
  ipv4acls                   => ['hostssl all johndoe 192.168.0.0/24 cert'],
  ip_mask_deny_postgres_user => '0.0.0.0/32',
  ip_mask_allow_all_users    => '0.0.0.0/0',
  postgres_password => 'postgres'
} ->
postgresql::server::db { 'airflow':
  user     => 'airflow',
  password => postgresql_password('airflow', 'airflow'),
} ->
class { '::airflow':
  load_examples => true
}
