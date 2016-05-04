# define: airflow::resource::service
# == Description: Creates a systemd service definition 
#
define airflow::resource::service(
  $service_name = $name,
  $pip_bin_path = $airflow::params::pip_bin_path
) {

  case $airflow::startup {

    'runit': {
      include ::runit
      runit::service { $service_name:
        enable  => true,
        logdir  => "/var/log/${service_name}",
        content => template("airflow/service/runit/${service_name}.conf.erb")
      }
      ->
      file { "/etc/init.d/${service_name}":
        ensure => link,
        target => '/usr/bin/sv'
      }
      ->
      service { $service_name:
        provider  => runit,
        path      => "/etc/service",
        ensure    => $airflow::service_ensure,
        enable    => $airflow::service_enable,
        subscribe =>
          [
            File["${airflow::home_folder}/airflow.cfg"]
          ]
      }
      exec { "wait-for-${service_name}":
        command     => '/bin/sleep 5',
        refreshonly => true,
        subscribe   => File["/etc/init.d/${service_name}"],
        before      => Service[$service_name]
      }
    }

    'systemd': {
      include ::systemd
      file { "${airflow::systemd_service_folder}/${service_name}.service":
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/service/systemd/${service_name}.service.erb"),
        require => [Python::Pip[$airflow::package_name], File[$airflow::log_folder]]
      } ~>
      Exec['systemctl-daemon-reload'] ->
      service { $service_name:
        ensure    => $airflow::service_ensure,
        enable    => $airflow::service_enable,
        subscribe =>
          [
            File["${airflow::systemd_service_folder}/${service_name}.service"],
            File["${airflow::home_folder}/airflow.cfg"]
          ]
      }

    }

    'upstart': {
      include ::airflow::resource::upstart
      file { "/etc/init/${service_name}.conf":
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/service/upstart/${service_name}.conf.erb"),
        require => [Python::Pip[$airflow::package_name], File[$airflow::log_folder]]
      } ~>
      Exec['initctl-reload-configuration'] ->
      service { $service_name:
        ensure    => $airflow::service_ensure,
        enable    => $airflow::service_enable,
        subscribe =>
          [
            File["/etc/init/${service_name}.conf"],
            File["${airflow::home_folder}/airflow.cfg"]
          ]
      }

    }
  }
}
