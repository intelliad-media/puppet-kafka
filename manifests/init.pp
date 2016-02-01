# = Kafka Global setup
# == Class: kafka
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Class for configuring the global kafka parameters for the kafka module.
# By default, the module will try to find the parameters in hiera. If the hiera lookup fails,
# it will fall back to the parameters passed to this class. The use of this class is optional,
# and will be automatically included through the configuration. If the ::kafka
# class is used, it needs appear first in node parse order to ensure proper variable
# initialization.
#
# == General
# [*ensure*]
#   ensure that kafka user, group and directories are `present` or `absent`
#   default to present
#
# [*java_install*]
#   Boolean. manage java installation by ::java Class
#   Defaults to false
#
# [*package_dir*]
#   Alternative installation directory for the kafka binaries
#   Defaults see ::kafka::params
#
# [*config_dir*]
#   Alternative configuration directory for the kafka daemons
#   Defaults see ::kafka::params
#
# [*user*]
#   The user which runs the daemons and owner of files
#   Defaults see ::kafka::params
#
# [*group*]
#   The group of the owned files
#   Defaults see ::kafka::params
#
# == Kafka install
# [*version*]
#   Default Kafka version which should be installed
#   Defaults see ::kafka::params
#
# [*scala_version*]
#   Default Scala version of the build kafka binaries
#   Defaults see ::kafka::params
#
# [*kafka_source*]
#   Optional download Source for the kafka binaries
#   see puppet-archive for valid sources
#   Default is unset
#
# == Service
# [*service_status*]
#   Default status of the configured services.
#   Valid values are 'enabled', 'disabled', 'running' and 'unmanaged',
#   Defaults to enabled
#
# [*service_restart*]
#   Boolean. Default if service should be restarted on config changes
#   Defaults to true
#
# [*service_provider*]
#   Set an specific default service provider
#   Default is got by puppet stdlib fact $::service_provider and depence on the running OS
#
# [*service_environment_broker*]
#   Hash. Add or overwrite default environment variables for the kafka broker.
#   These are usually parsed by kafka-run-class.sh
#   Defaults see ::kafka::params
#
# [*service_environment_mirror*]
#   Hash. Add or overwrite default environment variables for the kafka MirrorMaker.
#   These are usually parsed by kafka-run-class.sh
#   Defaults see ::kafka::params
#
# == MirrorMaker
# [*new_consumer*]
#   Boolean. Kafka 0.9 MirrorMaker introduces a new consumer api. This flag enables or disable the usage.
#   For Kafka less than 0.9 set to false
#   Defaults to true
#
# [*consumer_config*]
#   Hash. Add or overwrite default config for consumer config
#   Defaults see ::kafka::params
#
# [producer_config*]
#   Hash. Add or overwrite default config for producer config
#   Defaults see ::kafka::params
#
class kafka (
  $ensure = present,
  $java_install = $::kafka::params::java_install,
  $package_dir = $::kafka::params::package_dir,
  $config_dir = $::kafka::params::config_dir,
  $user = $::kafka::params::kafka_user,
  $group = $::kafka::params::kafka_user,
  $version = $::kafka::params::kafka_version,
  $scala_version = $::kafka::params::scala_version,
  $kafka_source = undef,
  $service_status = $::kafka::params::service_status,
  $service_restart = $::kafka::params::service_restart,
  $service_provider = $::kafka::params::service_provider,
  $service_environment_broker = $::kafka::params::service_environment_broker,
  $service_environment_mirror = $::kafka::params::service_environment_mirror,
  $new_consumer = $::kafka::params::new_consumer,
  $consumer_config = {},
  $producer_config = {},
) inherits kafka::params {

  validate_re($ensure, ['^present$', '^absent$'], "Invalid parameter ensure '${ensure}'")
  validate_bool($java_install)

  if $java_install and $ensure == present {
    include ::java
  }

  group { $group:
    ensure => $ensure,
  }

  user { $user:
    ensure  => $ensure,
    shell   => '/bin/bash',
    require => Group[$group],
  }

  $kafka_dirs = [$package_dir, $config_dir]

  if $ensure == present {
    file { $kafka_dirs:
      ensure => directory,
      owner  => $user,
      group  => $group,
    }
  }else {
    file { $kafka_dirs:
      ensure  => absent,
      force   => true,
      recurse => true,
    }
  }

  Class['kafka'] ->
  Kafka::Install <| |> ->
  Kafka::Config <| |> ->
  Kafka::Service <| |>
}
