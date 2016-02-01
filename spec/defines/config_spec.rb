require 'spec_helper'

config = {
  'int.option'    => '1000',
  'string.option' => 'value',
  'bool.option'   => 'true',
  'empty.option'  => '',
}
config_file = '/etc/kafka/test.conf'

describe 'kafka::config', :type => :define do
  context 'create config file' do
    let(:title) { config_file }
    let :params do
      {
        :ensure => 'present',
        :config => config,
      }
    end

    it "Will create #{config_file}" do
      should contain_file(config_file).with_ensure('present')
      should contain_file(config_file).with_content(/^int\.option=1000$/)
      should contain_file(config_file).with_content(/^string\.option=value$/)
      should contain_file(config_file).with_content(/^bool\.option=true$/)
      should contain_file(config_file).without_content(/empty\.option/)
    end
  end

  context 'remove config file' do
    let(:title) { config_file }
    let :params do
      {
        :ensure => 'absent',
      }
    end
    it { should contain_file(config_file).with_ensure('absent') }
  end
end
