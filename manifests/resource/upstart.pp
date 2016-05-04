class airflow::resource::upstart(
)
{
  exec { 'initctl-reload-configuration':
    command     => '/sbin/initctl reload-configuration',
    refreshonly => true
  }

}