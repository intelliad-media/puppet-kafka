require 'spec_helper'
describe 'kafka::service', type: :define do
  let :facts do
    {
      service_provider: 'systemd',
      path: '/bin:/usr/bin'
    }
  end

  let(:title) { 'my-service' }

  context 'with defaults for all parameters' do
    it { should compile }
    it { should contain_class('kafka') }
    it { should contain_file('/etc/systemd/system/kafka-my-service.service').with_ensure('present') }

    it do
      should contain_service('kafka-my-service').with(
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasstatus'  => 'true',
        'hasrestart' => 'true',
        'provider'   => 'systemd',
      )
    end
  end

  context 'with upstart provider' do
    let :params do
      {
        ensure: 'present',
        provider: 'upstart',
      }
    end
    it { should contain_file('/etc/init/kafka-my-service.conf').with_ensure('present') }
    it do
      should contain_service('kafka-my-service').with(
        'ensure'   => 'running',
        'enable'   => 'true',
        'provider' => 'upstart',
      )
    end
  end

  context 'with status enabled' do
    let :params do
      {
        ensure: 'present',
        status: 'enabled',
      }
    end
    it do
      should contain_service('kafka-my-service').with(
        'ensure'     => 'running',
        'enable'     => 'true'
      )
    end
  end

  context 'with status disabled' do
    let :params do
      {
        ensure: 'present',
        status: 'disabled',
      }
    end
    it do
      should contain_service('kafka-my-service').with(
        'ensure'     => 'stopped',
        'enable'     => 'false'
      )
    end
  end

  context 'with status running' do
    let :params do
      {
        ensure: 'present',
        status: 'running',
      }
    end
    it do
      should contain_service('kafka-my-service').with(
        'ensure'     => 'running',
        'enable'     => 'false'
      )
    end
  end

  context 'with status unmanaged' do
    let :params do
      {
        ensure: 'present',
        status: 'unmanaged',
      }
    end
    it do
      should contain_service('kafka-my-service').with(
        'ensure'     => nil,
        'enable'     => 'false'
      )
    end
  end

  context 'Raise error with invalid status' do
    let :params do
      {
        ensure: 'present',
        status: 'unknown',
      }
    end
    it do
      should raise_error(/"unknown" is an unknown service status value/)
    end
  end

  context 'remove service' do
    let :params do
      {
        ensure: 'absent',
      }
    end
    it do
      should contain_file('/etc/systemd/system/kafka-my-service.service').with_ensure('absent')
      should contain_service('kafka-my-service').with(
        'ensure'     => 'stopped',
        'enable'     => 'false'
      )
    end
  end
end
