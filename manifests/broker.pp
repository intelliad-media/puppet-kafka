# = Kafka Broker daemon
# == Class: kafka::broker
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Setups the Kafka Broker daemon
#
# == General
# [*ensure*]
#   ensure that service and config are `present` or `absent`
#   default to present
#
# == Kafka install
# Set specific kafka version which the daemon should running
#
# [*version*]
#   Kafka version which should be installed
#   Defaults from ::kafka
#
# [*scala_version*]
#   Scala version of the build kafka binaries
#   Defaults from ::kafka
#
# [*kafka_source*]
#   Optional download Source for the kafka binaries
#   see puppet-archive for valid sources
#   Defaults from ::kafka
#
# == Service
# [*service_status*]
#   Service status of kafka broker.
#   Valid values are 'enabled', 'disabled', 'running' and 'unmanaged',
#   Defaults to enabled
#
# [*service_restart*]
#   Should the ervice be restarted on config changes
#   Defaults from ::kafka
#
# [*service_provider*]
#   Set an specific service provider
#   Defaults from ::kafka
#
# [*service_environment*]
#   Hash. Add or overwrite environment variables for the kafka broker.
#   These are usually parsed by kafka-run-class.sh
#   Defaults from ::kafka
#
# == Broker
#
# [*config*]
#   Hash. Add or overwrite config settings
#   Defaults from ::kafka::params
#
class kafka::broker(
  $ensure = present,
  $version = undef,
  $scala_version = undef,
  $kafka_source = undef,
  $service_status = undef,
  $service_restart = undef,
  $service_provider = undef,
  $service_environment = {},
  $config = {},
) {
  include ::kafka

  # pick up given or default parameter
  $this_version = pick($version, $::kafka::version)
  $this_scala_version = pick($scala_version, $::kafka::scala_version)
  $this_service_status = pick($service_status, $::kafka::service_status)
  $this_service_restart = pick($service_restart, $::kafka::service_restart)
  $this_service_provider = pick($service_provider, $::kafka::service_provider)

  validate_bool($this_service_restart)

  if $::kafka::ensure == absent and $ensure == present {
    fail('You are going to remove kafka while kafka broker should be still present')
  }

  $kafka_target = "${::kafka::package_dir}/${this_scala_version}-${this_version}"
  $service_name = 'server'

  $notify = $this_service_restart ? {
    true    => Service["kafka-${service_name}"],
    default => undef,
  }

  if $ensure == present {
    ensure_resource(
      'kafka::install',
      $kafka_target,
      {
        'version'       => $this_version,
        'scala_version' => $this_scala_version,
        'kafka_source'  => pick_default($kafka_source, $::kafka::kafka_source),
      }
    )
  }

  $config_file = '/etc/kafka/server.properties'

  kafka::config { $config_file:
    ensure => $ensure,
    config => deep_merge($::kafka::params::broker_config_defaults, $config),
    notify => $notify,
  }

  # kafka server needs only an config file as option/arg
  $options = $config_file
  kafka::service { $service_name:
    ensure       => $ensure,
    status       => $this_service_status,
    restart      => $this_service_restart,
    provider     => $this_service_provider,
    classname    => 'kafka.Kafka',
    options      => $options,
    kafka_target => $kafka_target,
    environment  => deep_merge($::kafka::service_environment_broker, $service_environment),
  }

}
