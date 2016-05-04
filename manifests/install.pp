# == Class airflow::install
#
# This class is called from airflow for install.
#
class airflow::install(
  $pip_ensure = latest
){
  if ($lsbdistcodename == 'jessie') {
    include ::apt
    apt::source { 'debian_backports':
      location    => 'http://http.debian.net/debian',
      release     => 'jessie-backports',
      repos       => 'main',
      include_src => false,
      notify      => Exec['apt_update']
    } ->
    class { 'apt::backports':
      pin => 500,
    }
    package { 'python-requests':
      ensure  => '2.8.1-1~bpo8+1',
      require => Exec['apt_update'],
      before  => Class['python']
    }

  }
  # Install python and airflow dpkg/rpm dependencies
  class {
    '::python':
      dev      => present,
      pip      => absent,
      provider => pip
  } ->
  package {
    $airflow::prerequisite_packages:
      ensure => present,
  } ->
  anchor { 'airflow_install_pre_anchor': }

  # Create the users and groups - used potentially by vcs airflow install
  group { $airflow::group:
    ensure => 'present',
    name   => $airflow::group,
    gid    => $airflow::gid,
  } ->
  user { $airflow::user:
    ensure     => 'present',
    shell      => $airflow::shell,
    managehome => true,
    uid        => $airflow::uid,
    gid        => $airflow::group
  } ->
  # Create airflow base home folders
  file { $airflow::home_folder:
    ensure  => directory,
    owner   => $airflow::user,
    group   => $airflow::group,
    mode    => $airflow::folders_mode,
    recurse => true
  }

  if ($airflow::git_repo) {
    ensure_resource('package', 'git', {'ensure' => 'present'})
    Package['git'] -> Anchor['airflow_install_pre_pip_install']
    $install_args = "--pre"
    $url = "git+${airflow::git_repo}@${airflow::git_ref}"
  } else {
    $install_args = undef
    $url = undef
  }

  anchor { 'airflow_install_pre_pip_install': }

  if ($airflow::install_flower) {
    python::pip {'flower':
      before       => Python::Pip[$airflow::package_name],
      require      => Anchor['airflow_install_pre_anchor']
    }
  }
  python::pip {
    $airflow::package_name:
      pkgname      => $airflow::package_name,
      install_args => $install_args,
      url          => $url,
      ensure       => $airflow::version,
      require      => Anchor['airflow_install_pre_anchor'],
      notify       => Exec['airflow-initdb']
  } ->
  python::pip {
    $airflow::subpackages:
      install_args => $install_args,
      url          => $url,
      ensure       => present
  } ->
  anchor { 'airflow_install_post_anchor': }

  class { "::airflow::database::${::airflow::database}":
    install_args => $install_args,
    url          => $url,
    before       => Exec['airflow-initdb']
  }
}
