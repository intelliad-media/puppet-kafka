# = Kafka MirrorMaker daemon
# == Class: kafka::mirror
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Setups an Kafka MirrorMaker daemon
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
#   Hash. Add or overwrite environment variables for the kafka MirrorMaker.
#   These are usually parsed by kafka-run-class.sh
#   Defaults from ::kafka
#
# == MirrorMaker
# [*consumer_config*]
#   Hash. Add or overwrite config settings for consumer api
#   Defaults from ::kafka
#
# [*producer_config*]
#   Hash. Add or overwrite config settings for producer api
#   Defaults from ::kafka
#
# [*whitelist*]
#   Sets the topic whitelist
#   Set to undef if blacklist is used
#   Defaults to '.*'
#
# [*blacklist*]
#   Sets the topic blacklist
#   Default is unset
#
# [*new_consumer*]
#   Boolean. Requires Kafka 0.9. Enables or disable new consumer api
#   Default is true
#
# [*num_streams*]
#   Integer. Number of consumer threads
#   Default is unset (MirrorMaker default)
#
# [*num_producers*]
#   Integer. Number of producer threads
#   Incompatible with Kafka 0.9
#   Default is unset (MirrorMaker default)
#
# [*abort_on_failure*]
#   Boolean.
#   Default is unset (MirrorMaker default)
#
# [*offset_commit_interval*]
#   Integer.
#   Default is unset (MirrorMaker default)
#
# [*rebalance_listener_args*]
#   Default is unset (MirrorMaker default)
#
# [*message_handler*]
#   Default is unset (MirrorMaker default)
#
define kafka::mirror (
  $ensure = present,
  $version = undef,
  $scala_version = undef,
  $kafka_source = undef,
  $service_status = undef,
  $service_restart = undef,
  $service_provider = undef,
  $service_environment = {},
  $consumer_config = {},
  $producer_config = {},
  $whitelist = '.*',
  $blacklist = undef,
  $new_consumer = undef,
  $num_streams = undef,
  $num_producers = undef,
  $abort_on_failure = undef,
  $offset_commit_interval = undef,
  $rebalance_listener_args = undef,
  $message_handler = undef,
) {
  include ::kafka

  # pick up given or default parameter
  $this_version = pick($version, $::kafka::version)
  $this_scala_version = pick($scala_version, $::kafka::scala_version)
  $this_service_status = pick($service_status, $::kafka::service_status)
  $this_service_restart = pick($service_restart, $::kafka::service_restart)
  $this_new_consumer = pick($new_consumer, $::kafka::new_consumer)
  $this_service_provider = pick($service_provider, $::kafka::service_provider)

  validate_bool($this_service_restart)

  if $::kafka::ensure == absent and $ensure == present {
    fail('You are going to remove kafka while kafka mirror should be still present')
  }

  if ($whitelist == undef and $blacklist == undef) or ($whitelist != undef and $blacklist != undef) {
    fail('Please specify whitelist or blacklist')
  }

  if $this_new_consumer and $blacklist != undef {
    fail('New consumer allows only whitelist')
  }

  if $this_new_consumer and versioncmp($this_version , '0.9.0.0') < 0 {
    fail('New consumer is only available at kafka 0.9.0.0 and above')
  }

  $kafka_target = "${::kafka::package_dir}/${this_scala_version}-${this_version}"
  $service_name = $name

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

  # Build config
  $config_file_consumer = "/etc/kafka/${service_name}.consumer.properties"
  $config_file_producer = "/etc/kafka/${service_name}.producer.properties"

  if $this_new_consumer {
    $this_consumer_config_defaults = $::kafka::params::consumer_new_config_defaults
  } else {
    $this_consumer_config_defaults = $::kafka::params::consumer_config_defaults
  }

  # new producer is default at 0.9
  if versioncmp($this_version , '0.9.0.0') >= 0 {
    $this_producer_config_defaults = $::kafka::params::producer_new_config_defaults
  } else {
    $this_producer_config_defaults = $::kafka::params::producer_config_defaults
  }

  kafka::config { $config_file_consumer:
    ensure => $ensure,
    config => deep_merge($this_consumer_config_defaults, $consumer_config),
    notify => $notify,
  }

  kafka::config { $config_file_producer:
    ensure => $ensure,
    config => deep_merge($this_producer_config_defaults, $producer_config),
    notify => $notify,
  }

  # Build options
  $options_basic = [
    '--consumer.config', $config_file_consumer,
    '--producer.config', $config_file_producer,
  ]

  if $this_new_consumer == true {
    $option_consumer = '--new.consumer'
  }

  unless $whitelist == undef {
    $option_whitelist = "--whitelist='${whitelist}'"
  }

  unless $blacklist == undef {
    $option_blacklist = "--blacklist='${blacklist}'"
  }

  if is_integer($num_streams) {
    $option_numstreams = ['--num.streams', $num_streams]
  }

  if is_integer($num_producers) {
    $option_numproducers = ['--num.producers', $num_producers]
  }

  if is_bool($abort_on_failure) {
    $option_abort = ['--abort.on.send.failure', bool2str($abort_on_failure)]
  }

  if is_integer($offset_commit_interval) {
    $option_offset = ['--offset.commit.interval.ms', $offset_commit_interval]
  }

  unless $rebalance_listener_args == undef {
    $option_rebalance = ['--rebalance.listener.args', $rebalance_listener_args]
  }

  unless $message_handler == undef {
    $option_message = ['--message.handler.args', $message_handler]
  }

  $options = flatten(delete_undef_values([
    $options_basic,
    $option_whitelist,
    $option_blacklist,
    $option_consumer,
    $option_numstreams,
    $option_numproducers,
    $option_abort,
    $option_offset,
    $option_rebalance,
    $option_message,
  ]))

  kafka::service { $service_name:
    ensure       => $ensure,
    status       => $this_service_status,
    restart      => $this_service_restart,
    provider     => $this_service_provider,
    classname    => 'kafka.tools.MirrorMaker',
    options      => join($options,' '),
    kafka_target => $kafka_target,
    environment  => deep_merge($::kafka::service_environment_mirror, $service_environment),
  }

}
