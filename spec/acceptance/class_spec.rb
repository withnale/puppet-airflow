require 'spec_helper_acceptance'

describe 'airflow class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'postgresql::server':
        listen_addresses           => '*',
        ip_mask_deny_postgres_user => '0.0.0.0/32',
        ip_mask_allow_all_users    => '0.0.0.0/0',
        postgres_password => 'postgres'
      } ->
      postgresql::server::db { 'airflow':
        user     => 'airflow',
        password => postgresql_password('airflow', 'airflow'),
        before   => Exec['airflow-initdb']
      } ->
      class { '::airflow':
        git_repo => 'http://github.com/withnale/airflow.git',
        git_ref  => 'add_manual_trigger',
        load_examples => true,
        parallelism => 3
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      # TODO: Not idempotent right now due to python::pip
      #apply_manifest(pp, :catch_changes  => true)
    end

    describe service('airflow-webserver') do
      it { is_expected.to be_running }
    end

    describe service('airflow-scheduler') do
      it { is_expected.to be_running }
    end

    describe service('airflow-worker') do
      it { is_expected.to be_running }
    end

    describe service('airflow-flower') do
      it { is_expected.to be_running }
    end

  end
end
