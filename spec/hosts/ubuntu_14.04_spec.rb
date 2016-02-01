require 'spec_helper'

describe 'ubuntu.example.com' do
  let :facts do
    {
      :osfamily => 'Debian',
      :lsbdistcodename => 'trusty',
      :lsbdistdescription => 'Ubuntu 14.04.1 LTS',
      :lsbdistid => 'Ubuntu',
      :lsbdistrelease => '14.04',
      :lsbmajdistrelease => '14',
      :service_provider => 'upstart',
      :path => '/bin:/usr/bin',
    }
  end

  context 'with defaults for all parameters' do
    it { should compile }
    it { should contain_class('kafka') }
  end
end
