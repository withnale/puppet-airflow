# define: airflow::resource::service
# == Description: Creates a systemd service definition 
#
define airflow::resource::airflow_package(
  $package_name = $name,
  $pip_bin_path = $airflow::params::pip_bin_path,
  $ensure       = present
) {

  if ($airflow::git_repo == undef)
    python::pip { $package_name:
      install_options => "-e ${airflow::home_directory}/repo",
      ensure => $ensure
    }
  } else {
    python::pip { $package_name:
      install_options => "-e ${airflow::home_directory}/repo",
      ensure => $ensure
    }
  }
}
