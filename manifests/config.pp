# == Define: kafka::config
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Manage config files by Hash
# Used by kafka::mirror and kafka::broker
#
define kafka::config (
  $ensure,
  $config = undef,
  $config_file = $title,
) {
  include ::kafka

  if $ensure == present {
    file { $config_file:
      ensure  => present,
      content => template('kafka/config.erb'),
      owner   => $::kafka::user,
      group   => $::kafka::group,
    }
  } else {
    file { $config_file:
      ensure  => absent,
    }
  }

}
