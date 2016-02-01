require 'spec_helper'
describe 'kafka', :type => :class do
  context 'with defaults for all parameters' do
    it { should compile }

    it { should contain_class('kafka') }

    it 'Will create user and group' do
      should contain_user('kafka').with_ensure('present')
      should contain_group('kafka').with_ensure('present')
    end

    it 'Will create directory /etc/kafka' do
      should contain_file('/etc/kafka').with_ensure('directory')
    end
  end

  context 'Fail on invalid ensure parameters' do
    let :params do
      {
        :ensure => 'myensure',
      }
    end
    it { should compile.and_raise_error(/Invalid parameter ensure/) }
  end

  context 'Remove kafka directories and user/group' do
    let :params do
      {
        :ensure => 'absent',
      }
    end
    it { should contain_file('/etc/kafka').with_ensure('absent') }
    it { should contain_file('/var/lib/kafka').with_ensure('absent') }
    it { should contain_user('kafka').with_ensure('absent') }
    it { should contain_group('kafka').with_ensure('absent') }
  end
end
