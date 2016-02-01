# == Define: kafka::service
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Manage kafka service daemons with support of several providers
# Used by kafka::mirror and kafka::broker
#
define kafka::service (
  $ensure       = present,
  $status       = 'enabled',
  $restart      = true,
  $provider     = $::service_provider,
  $classname    = undef,
  $options      = undef,
  $kafka_target = undef,
  $environment  = {},
) {

  include ::kafka

  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }
  } else {
    # make sure the service is stopped and disabled
    $service_ensure = 'stopped'
    $service_enable = false
  }

  $provider_dir = $::kafka::params::service_provider_dir[$provider]
  $service_name = "kafka-${name}"

  case $provider {
    'upstart': {
      $service_file = "${provider_dir}/${service_name}.conf"
    }
    'systemd': {
      $service_file = "${provider_dir}/${service_name}.service"

      exec {"kafka systemd systemctl-daemon-reload ${title}":
          command     => 'systemctl daemon-reload',
          refreshonly => true,
          path        => $::path,
          subscribe   => File[$service_file],
          before      => Service[$service_name],
      }
    }
    default: {
      fail("Service provider '${provider}' is not supported")
    }
  }

  $notify_service = $restart ? {
    true    => Service[$service_name],
    default => undef,
  }

  file { $service_file:
    ensure  => $ensure,
    owner   => root,
    group   => root,
    mode    => '0744',
    content => template("kafka/service/${provider}.erb"),
    notify  => $notify_service,
  }

  service { $service_name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => true,
    provider   => $provider,
  }
}
