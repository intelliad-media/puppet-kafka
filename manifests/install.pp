# == Define: kafka::install
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Manage kafka installation with archive provider
# Used by kafka::mirror and kafka::broker
#
define kafka::install (
  $version,
  $scala_version,
  $kafka_source = undef,
  $target = $title,
) {
  include ::kafka

  $archive_name = "kafka_${scala_version}-${version}.tgz"

  if $kafka_source == undef or $kafka_source == '' {
    $this_kafka_source = "http://www.eu.apache.org/dist/kafka/${version}/${archive_name}"
  } else {
    $this_kafka_source = $kafka_source
  }

  archive { "/tmp/${archive_name}":
    source       => $this_kafka_source,
    extract      => true,
    extract_path => $::kafka::package_dir,
    creates      => $target,
    user         => $::kafka::user,
    group        => $::kafka::group,
    require      => Class['::kafka'],
  }

}
