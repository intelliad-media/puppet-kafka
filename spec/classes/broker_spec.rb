require 'spec_helper'
describe 'kafka::broker', :type => :class do
  let :facts do
    {
      service_provider: 'systemd',
      path: '/bin:/usr/bin',
    }
  end

  context 'with defaults for all parameters' do
    it { should compile }
    it { should contain_class('kafka') }
    it { should have_kafka__install_resource_count(1) }
    it { should contain_kafka__config('/etc/kafka/server.properties').with_ensure('present') }
    it do
      should contain_kafka__service('server').with(
        'ensure'    => 'present',
        'status'    => 'enabled',
        'restart'   => 'true',
        'classname' => 'kafka.Kafka',
        'options'   => '/etc/kafka/server.properties',
        'environment' => {
          'KAFKA_HEAP_OPTS' => '-Xmx1G -Xms1G'
        },
      )
    end
  end

  context 'with custom parameters for install' do
    let :params do
      {
        :version => '0.8.2.1',
        :scala_version => '2.9',
        :kafka_source => 'http://domain.com/archive.tgz'
      }
    end

    it do
      should contain_kafka__install('/var/lib/kafka/kafka_2.9-0.8.2.1').with(
        'version'       => '0.8.2.1',
        'scala_version' => '2.9',
        'kafka_source'  => 'http://domain.com/archive.tgz',
      )
    end
  end

  context 'with custom parameters for config' do
    let :params do
      {
        :config => {
          'broker.id' => '0',
          'port'      => '6656',
          'host.name' => 'host.example.com',
        },
      }
    end

    it { should contain_file('/etc/kafka/server.properties').with_content(/^broker\.id=0$/) }
    it { should contain_file('/etc/kafka/server.properties').with_content(/^port=6656$/) }
    it { should contain_file('/etc/kafka/server.properties').with_content(/^host\.name=host.example.com$/) }
  end

  context 'with custom parameters for service' do
    let :params do
      {
        :service_status      => 'running',
        :service_provider    => 'upstart',
        :service_restart     => false,
        :service_environment => {
          'KAFKA_HEAP_OPTS' => '-Xmx4g -Xms2g',
          'JAVA_ENV_1'      => 'test env',
        },
      }
    end

    it do
      should contain_kafka__service('server').with(
        'ensure'      => 'present',
        'status'      => 'running',
        'restart'     => false,
        'provider'    => 'upstart',
        'environment' => {
          'KAFKA_HEAP_OPTS' => '-Xmx4g -Xms2g',
          'JAVA_ENV_1'      => 'test env',
        }
      )
    end
  end

  context 'Remove broker with ensure absent' do
    let :params do
      {
        :ensure => 'absent',
      }
    end

    it 'Should not contain this resources' do
      should have_kafka__install_resource_count(0)
    end
    it { should contain_kafka__config('/etc/kafka/server.properties').with_ensure('absent') }
    it { should contain_kafka__service('server').with_ensure('absent') }
  end
end
