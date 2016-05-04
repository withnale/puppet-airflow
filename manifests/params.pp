# == Class airflow::params
#
# This class is meant to be called from airflow.
# It sets variables according to platform.
#
class airflow::params {

  # Airflow service settings
  $service_ensure            = 'running'
  $service_enable            = true

  # Airflow install settings
  $version                   = '1.7.0'
  $database                  = 'postgres'
  $subpackages               = [ ]

  # User and group settings
  $user                      = 'airflow'
  $group                     = 'airflow'
  $user_home_folder          = "/home/${user}"
  $shell                     = '/bin/bash'
  $gid                       = 3000
  $uid                       = 3000
  $folders_mode              = '0775'

  # General settings
  $log_folder                = '/var/log/airflow'
  $run_folder                = '/var/run/airflow'
  $systemd_service_folder    = '/lib/systemd/system'

  # Airflow.cfg file
  ## Core settings
  $home_folder               = '/opt/airflow'
  $dags_folder               = "${home_folder}/dags"
  $s3_log_folder             = 'None'
  $executor                  = 'CeleryExecutor'
  $sql_alchemy_conn          = 'postgresql://airflow:airflow@localhost/airflow'
  $parallelism               = 32
  $dag_concurrency           = 16
  $max_active_runs_per_dag   = 16
  $load_examples             = false
  $plugins_folder            = "${home_folder}/plugins"
  $fernet_key                =
    'cryptography_not_found_storing_passwords_in_plain_text'
  $donot_pickle              = false

  ## Webserver settings
  $base_url                  = 'http://localhost'
  $web_server_host           = '0.0.0.0'
  $web_server_port           = 8080
  $secret_key                = 'temporary_key'
  $gunicorn_workers          = 4
  $worker_class              = 'sync'
  $expose_config             = true
  $authenticate              = false
  $auth_backend              = undef
  $filter_by_owner           = false

  ## Mail settings
  $smtp_host                 = 'localhost'
  $smtp_starttls             = true
  $smtp_user                 = 'airflow'
  $smtp_port                 = 25
  $smtp_password             = 'airflow'
  $smtp_mail_from            = 'airflow@airflow.com'

  ## Celery settings
  $celery_app_name           = 'airflow.executors.celery_executor'
  $celeryd_concurrency       = 16
  $worker_log_server_port    = 8793
  $broker_url                = 'sqla+postgresql://airflow:airflow@localhost/airflow'
  $celery_result_backend     = 'db+postgresql://airflow:airflow@localhost/airflow'
  $flower_port               = 5555
  $default_queue             = 'default'

  ## Scheduler settings
  $job_heartbeat_sec         = 5
  $scheduler_heartbeat_sec   = 5

  ### START hiera lookups ###
  $ldap_settings             = {}
  $statsd_settings           = {}
  $mesos_settings            = {}
  ### END hiera lookups ###

  case $::lsbdistid {
    'Debian': {
      $package_name = 'airflow'
      $service_name = 'airflow'
      $prerequisite_packages = [ 'g++', 'cython' ]
      $prerequisite_postgres = [ 'libpq-dev' ]
      if ($lsbdistcodename == 'jessie') {
        $startup = 'systemd'
      } else {
        $startup = 'runit'
      }
      $pip_bin_path = '/usr/local/bin'
    }
    'Ubuntu': {
      $package_name = 'airflow'
      $service_name = 'airflow'
      $pip_bin_path = '/usr/local/bin'
      $prerequisite_postgres = [ 'libpq-dev' ]
      case $::lsbmajdistrelease {
        '12.04': {
          $prerequisite_packages = [ ]
          $startup = 'upstart'
        }
        '14.04': {
          $prerequisite_packages = [ 'g++', 'cython']
          $startup = 'upstart'
        }
        default: {
          $prerequisite_packages = [ 'g++']
          $startup = 'systemd'
        }
      }
    }
    'RedHat', 'Amazon': {
      $startup = 'systemd'
      $package_name = 'airflow'
      $service_name = 'airflow'
      $prerequisite_packages = [ ]
      $prerequisite_postgres = [ 'libpq-dev' ]
      $pip_bin_path = '/usr/local/bin'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
