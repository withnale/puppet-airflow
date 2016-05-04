class airflow::database::postgres(
  $install_args = undef,
  $url = undef
)
{
  package { 'libpq-dev':
    ensure => present
  } ->
  python::pip { 'psycopg2': } ->
  python::pip {
    'airflow[postgres]':
      #install_args => $install_args,
      install_args => $install_args,
      url          => $url,
      require      => Anchor['airflow_install_pre_pip_install'],
      before       => Exec['airflow-initdb'],
      ensure       => present
  }
}