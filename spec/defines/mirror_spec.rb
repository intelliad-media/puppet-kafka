require 'spec_helper'
describe 'kafka::mirror', type: :define do
  let :facts do
    {
      service_provider: 'systemd',
      path: '/bin:/usr/bin'
    }
  end

  let(:title) { 'mirror' }

  context 'with defaults for all parameters' do
    it { should compile }
    it { should contain_class('kafka') }
    it { should have_kafka__install_resource_count(1) }
    it { should contain_kafka__config('/etc/kafka/mirror.consumer.properties').with_ensure('present') }
    it { should contain_kafka__config('/etc/kafka/mirror.producer.properties').with_ensure('present') }
    it do
      should contain_kafka__service('mirror').with(
        'ensure'      => 'present',
        'status'      => 'enabled',
        'restart'     => 'true',
        'classname'   => 'kafka.tools.MirrorMaker',
        'environment' => {},
        'options'     => %r{--consumer\.config /etc/kafka/mirror\.consumer\.properties --producer\.config /etc/kafka/mirror\.producer\.properties}
      )
    end
  end

  context 'with custom parameters for install' do
    let :params do
      {
        version: '0.8.2.1',
        scala_version: '2.9',
        kafka_source: 'http://domain.com/archive.tgz',
        new_consumer: false
      }
    end

    it do
      should contain_kafka__install('/var/lib/kafka/kafka_2.9-0.8.2.1').with(
        'version'       => '0.8.2.1',
        'scala_version' => '2.9',
        'kafka_source'  => 'http://domain.com/archive.tgz'
      )
    end
  end

  context 'with custom parameters for config' do
    let :params do
      {
        consumer_config: {
          'group.id'           => 'kafka_group',
          'auto.commit.enable' => 'false'
        },
        producer_config: {
          'client.id'        => 'myid',
          'retry.backoff.ms' => '500'
        }
      }
    end

    it do
      should contain_file('/etc/kafka/mirror.consumer.properties').with_content(/^group\.id=kafka_group$/)
      should contain_file('/etc/kafka/mirror.consumer.properties').with_content(/^auto\.commit\.enable=false$/)
    end
    it do
      should contain_file('/etc/kafka/mirror.producer.properties').with_content(/^client\.id=myid$/)
      should contain_file('/etc/kafka/mirror.producer.properties').with_content(/^retry\.backoff\.ms=500$/)
    end
  end

  context 'with custom parameters for service' do
    let :params do
      {
        service_status: 'running',
        service_provider: 'upstart',
        service_restart: false,
        service_environment: {
          'KAFKA_HEAP_OPTS' => '-Xmx4g -Xms2g',
          'JAVA_ENV_1'      => 'test env'
        }
      }
    end

    it do
      should contain_kafka__service('mirror').with(
        'ensure'      => 'present',
        'status'      => 'running',
        'restart'     => false,
        'provider'    => 'upstart',
        'environment' => {
          'KAFKA_HEAP_OPTS' => '-Xmx4g -Xms2g',
          'JAVA_ENV_1'      => 'test env'
        }
      )
    end
  end

  context 'Custom mirrormaker arguments with default 0.9' do
    let :params do
      {
        whitelist: 'topic.*',
        new_consumer: false,
        num_streams: 10,
        abort_on_failure: false,
        offset_commit_interval: 1000,
        rebalance_listener_args: 'arg,arg',
        message_handler: 'my.handler.class'

      }
    end

    it 'Add additional options/arguments to kafka-run-class' do
      should contain_kafka__service('mirror').with_options(/--whitelist='topic\.\*'/)
      should contain_kafka__service('mirror').without_options(/--new\.consumer/)
      should contain_kafka__service('mirror').with_options(/--num\.streams 10/)
      should contain_kafka__service('mirror').with_options(/--abort\.on\.send\.failure false/)
      should contain_kafka__service('mirror').with_options(/--offset\.commit\.interval.ms 1000/)
      should contain_kafka__service('mirror').with_options(/--rebalance\.listener\.args arg,arg/)
      should contain_kafka__service('mirror').with_options(/--message\.handler\.args my.handler.class/)
    end
  end

  context 'Remove mirror with ensure absent' do
    let :params do
      {
        ensure: 'absent'
      }
    end

    it 'Should not contain this resources' do
      should have_kafka__install_resource_count(0)
    end
    it { should contain_kafka__config('/etc/kafka/mirror.producer.properties').with_ensure('absent') }
    it { should contain_kafka__config('/etc/kafka/mirror.consumer.properties').with_ensure('absent') }
    it { should contain_kafka__service('mirror').with_ensure('absent') }
  end
end
