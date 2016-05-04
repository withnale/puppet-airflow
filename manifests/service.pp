# == Class airflow::service
#
# This class is meant to be called from airflow.
# It ensure the service is running.
#
class airflow::service {

  service { $::airflow::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
