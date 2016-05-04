# == Class airflow::config
#
# This class is called from airflow for service config.
#
class airflow::config {
  # Create airflow folders
  $airflow_folders =
    [
      $airflow::log_folder,$airflow::run_folder,
      $airflow::dags_folder,$airflow::plugins_folder
    ]
  if $airflow::repo_folder {
    file { $airflow::repo_folder:
      ensure  => directory,
      owner   => $airflow::user,
      group   => $airflow::group,
      mode    => $airflow::folders_mode,
      require => File[$airflow::home_folder],
      before  => File[$airflow::dags_folder]
    }
  }
  file { $airflow_folders:
    ensure  => directory,
    owner   => $airflow::user,
    group   => $airflow::group,
    mode    => $airflow::folders_mode,
    require => File[$airflow::home_folder],
    notify  => Exec['airflow-initdb']
  }
  # Set the AIRFLOW_HOME environment variable on the server
  file { "${airflow::user_home_folder}/.bash_profile":
    content => inline_template("AIRFLOW_HOME=${airflow::home_folder}")
  }
  # Setup airflow.cfg configuration file
  file { "${airflow::home_folder}/airflow.cfg":
    ensure  => 'file',
    content => template("${module_name}/airflow.cfg.erb"),
    mode    => '0755',
    require => Anchor['airflow_install_pre_anchor'],
  }

  exec { 'airflow-initdb':
    command     => "${airflow::params::pip_bin_path}/airflow initdb",
    environment => "AIRFLOW_HOME=${airflow::home_folder}",
    user        => $airflow::user,
    group       => $airflow::group,

    refreshonly => true,
    require     => [
      Class['::airflow::install'],
      File["${airflow::home_folder}/airflow.cfg"]
    ]
  }
}
