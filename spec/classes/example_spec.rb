require 'spec_helper'

describe 'airflow' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "airflow class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('airflow::params') }
          it { is_expected.to contain_class('airflow::install').that_comes_before('airflow::config') }
          it { is_expected.to contain_class('airflow::config') }
          it { is_expected.to contain_class('airflow::service').that_subscribes_to('airflow::config') }

          it { is_expected.to contain_service('airflow') }
          it { is_expected.to contain_package('airflow').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'airflow class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('airflow') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
