require 'spec_helper'

kafka_version = '0.9.0.0'
scala_version = '2.11'
kafka_target = "kafka_#{scala_version}-#{kafka_version}"

describe 'kafka::install', :type => :define do
  context 'Install Kafka with archive' do
    let(:title) { "/var/lib/kafka/#{kafka_target}" }
    let :params do
      {
        :version => kafka_version,
        :scala_version => scala_version,
      }
    end
    it do
      should contain_archive("/tmp/#{kafka_target}.tgz").with(
        'source'       => "http://www.eu.apache.org/dist/kafka/#{kafka_version}/#{kafka_target}.tgz",
        'extract'      => true,
        'extract_path' => '/var/lib/kafka',
        'creates'      => "/var/lib/kafka/#{kafka_target}",
        'user'         => 'kafka',
        'group'        => 'kafka'
      )
    end
  end

  context 'Install Kafka with archive and custom source download' do
    let(:title) { "/var/lib/kafka/#{kafka_target}" }
    let :params do
      {
        :version => kafka_version,
        :scala_version => scala_version,
        :kafka_source => 'http://domain.com/archive.tgz'
      }
    end
    it do
      should contain_archive("/tmp/#{kafka_target}.tgz").with(
        'source' => 'http://domain.com/archive.tgz',
      )
    end
  end
end
