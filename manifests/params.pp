# == Class: kafka::params
#
# === Authors
#
# Richard Hillmann <rhillmann@intelliad.de>
#
# === Copyright
#
# Copyright 2016 intellAd Media GmbH.
#
# Default Parameters for the Kafka Module
#
class kafka::params {

  $kafka_version = '0.9.0.0'
  $scala_version = '2.11'

  $kafka_user = 'kafka'
  $kafka_group = 'kafka'

  $package_dir = '/var/lib/kafka'
  $config_dir = '/etc/kafka'

  # should java be installed by module
  $java_install = false

  # service status
  $service_status = 'enabled'

  # restart on configuration change?
  $service_restart = true

  case $::osfamily {
    'Ubuntu': {
      if versioncmp( $::lsbmajdistrelease, '15') >= 0 {
        $service_provider = 'systemd'
      } else {
        $service_provider = 'upstart'
      }
    }
    default: {
      # determine default service provider by stdlib fact
      $service_provider = $::service_provider
    }
  }

  $service_provider_dir = {
    'upstart' => '/etc/init',
    'systemd' => '/etc/systemd/system'
  }

  $new_consumer = true

  # Java Heap size etc...
  $service_environment_broker =  {
    'KAFKA_HEAP_OPTS'  => '-Xmx1G -Xms1G',
  }
  $service_environment_mirror = {}

  # http://kafka.apache.org/documentation.html#brokerconfigs
  $broker_config_defaults = {
    'broker.id'                                     => '0',
    'log.dirs'                                      => '/tmp/kafka-logs',
    'port'                                          => '6667',
    'zookeeper.connect'                             => '',
    'message.max.bytes'                             => '1000000',
    'num.network.threads'                           => '3',
    'num.io.threads'                                => '8',
    'background.threads'                            => '4',
    'queued.max.requests'                           => '500',
    'host.name'                                     => '',
    'advertised.host.name'                          => '',
    'advertised.port'                               => '',
    'socket.send.buffer.bytes'                      => '102400',
    'socket.receive.buffer.bytes'                   => '102400',
    'socket.request.max.bytes'                      => '104857600',
    'num.partitions'                                => '1',
    'log.segment.bytes'                             => '1073741824',
    'log.roll.hours'                                => '168',
    'log.cleanup.policy'                            => 'delete',
    'log.retention.hours'                           => '168',
    'log.retention.minutes'                         => '10080',
    'log.retention.bytes'                           => '-1',
    'log.retention.check.interval.ms'               => '300000',
    'log.cleaner.enable'                            => false,
    'log.cleaner.threads'                           => '1',
    'log.cleaner.io.max.bytes.per.second'           => '',
    'log.cleaner.dedupe.buffer.size'                => '524288000',
    'log.cleaner.io.buffer.size'                    => '524288',
    'log.cleaner.io.buffer.load.factor'             => '0.9',
    'log.cleaner.backoff.ms'                        => '15000',
    'log.cleaner.min.cleanable.ratio'               => '0.5',
    'log.cleaner.delete.retention.ms'               => '86400000',
    'log.index.size.max.bytes'                      => '10485760',
    'log.index.interval.bytes'                      => '4096',
    'log.flush.interval.messages'                   => '',
    'log.flush.scheduler.interval.ms'               => '3000',
    'log.flush.interval.ms'                         => '',
    'log.delete.delay.ms'                           => '60000',
    'log.flush.offset.checkpoint.interval.ms'       => '60000',
    'auto.create.topics.enable'                     => true,
    'controller.socket.timeout.ms'                  => '30000',
    'controller.message.queue.size'                 => '10',
    'default.replication.factor'                    => '1',
    'replica.lag.time.max.ms'                       => '10000',
    'replica.lag.max.messages'                      => '4000',
    'replica.socket.timeout.ms'                     => '30000',
    'replica.socket.receive.buffer.bytes'           => '65536',
    'replica.fetch.max.bytes'                       => '1048576',
    'replica.fetch.wait.max.ms'                     => '500',
    'replica.fetch.min.bytes'                       => '1',
    'num.replica.fetchers'                          => '1',
    'replica.high.watermark.checkpoint.interval.ms' => '5000',
    'fetch.purgatory.purge.interval.requests'       => '10000',
    'producer.purgatory.purge.interval.requests'    => '10000',
    'zookeeper.session.timeout.ms'                  => '6000',
    'zookeeper.connection.timeout.ms'               => '6000',
    'zookeeper.sync.time.ms'                        => '2000',
    'controlled.shutdown.enable'                    => true,
    'controlled.shutdown.max.retries'               => '3',
    'controlled.shutdown.retry.backoff.ms'          => '5000',
    'auto.leader.rebalance.enable'                  => true,
    'leader.imbalance.per.broker.percentage'        => '10',
    'leader.imbalance.check.interval.seconds'       => '300',
    'offset.metadata.max.bytes'                     => '1024',
  }

  # legacy consumer config
  # http://kafka.apache.org/documentation.html#oldconsumerconfigs
  $consumer_config_defaults = {
    'group.id'                        => '',
    'zookeeper.connect'               => '',
    'consumer.id'                     => '',
    'socket.timeout.ms'               => '30000',
    'socket.receive.buffer.bytes'     => '65536',
    'fetch.message.max.bytes'         => '1048576',
    'auto.commit.enable'              => true,
    'auto.commit.interval.ms'         => '10000',
    'queued.max.message.chunks'       => '10',
    'rebalance.max.retries'           => '4',
    'fetch.min.bytes'                 => '1',
    'fetch.wait.max.ms'               => '100',
    'rebalance.backoff.ms'            => '2000',
    'refresh.leader.backoff.ms'       => '200',
    'auto.offset.reset'               => 'largest',
    'consumer.timeout.ms'             => '-1',
    'client.id'                       => '',
    'zookeeper.session.timeout.ms'    => '6000',
    'zookeeper.connection.timeout.ms' => '6000',
    'zookeeper.sync.time.ms'          => '2000',
  }

  # legacy producer config, not available at 0.9 and above
  # http://kafka.apache.org/082/documentation.html#producerconfigs
  $producer_config_defaults = {
    'metadata.broker.list'               => '',
    'request.required.acks'              => '0',
    'request.timeout.ms'                 => '10000',
    'producer.type'                      => 'sync',
    'serializer.class'                   => 'kafka.serializer.DefaultEncoder',
    'key.serializer.class'               => '',
    'partitioner.class'                  => 'kafka.producer.DefaultPartitioner',
    'compression.codec'                  => 'none',
    'compressed.topics'                  => '',
    'message.send.max.retries'           => '3',
    'retry.backoff.ms'                   => '100',
    'topic.metadata.refresh.interval.ms' => '600000',
    'queue.buffering.max.ms'             => '5000',
    'queue.buffering.max.messages'       => '10000',
    'queue.enqueue.timeout.ms'           => '-1',
    'batch.num.messages'                 => '200',
    'send.buffer.bytes'                  => '102400',
    'client.id'                          => '',
  }

  # 0.9.0.0 has a new consumer
  # http://kafka.apache.org/documentation.html#newconsumerconfigs
  $consumer_new_config_defaults = {
    'bootstrap.servers'                        => '',
    'key.deserializer'                         => '',
    'value.deserializer'                       => '',
    'fetch.min.bytes'                          => '1024',
    'group.id'                                 => '',
    'heartbeat.interval.ms'                    => '3000',
    'max.partition.fetch.bytes'                => '1048576',
    'session.timeout.ms'                       => '30000',
    'auto.offset.reset'                        => 'latest',
    'connections.max.idle.ms'                  => '540000',
    'enable.auto.commit'                       => true,
    'partition.assignment.strategy'            => 'org.apache.kafka.clients.consumer.RangeAssignor',
    'receive.buffer.bytes'                     => '32768',
    'request.timeout.ms'                       => '40000',
    'send.buffer.bytes'                        => '131072',
    'auto.commit.interval.ms'                  => '5000',
    'check.crcs'                               => true,
    'client.id'                                => '',
    'fetch.max.wait.ms'                        => '500',
    'metadata.max.age.ms'                      => '300000',
    'metric.reporters'                         => '',
    'metrics.num.samples'                      => '2',
    'metrics.sample.window.ms'                 => '30000',
    'reconnect.backoff.ms	'                    => '50',
    'retry.backoff.ms'                         => '100',
    'security.protocol'                        => 'PLAINTEXT',
    'sasl.kerberos.service.name'               => '',
    'sasl.kerberos.kinit.cmd'                  => '/usr/bin/kinit',
    'sasl.kerberos.min.time.before.relogin'    => '60000',
    'sasl.kerberos.ticket.renew.jitter'        => '0.05',
    'sasl.kerberos.ticket.renew.window.factor' => '0.8',
    'ssl.key.password'                         => '',
    'ssl.keystore.location'                    => '',
    'ssl.keystore.password'                    => '',
    'ssl.keystore.type'                        => 'JKS',
    'ssl.truststore.location'                  => '',
    'ssl.truststore.password'                  => '',
    'ssl.truststore.type'                      => 'JKS',
    'ssl.enabled.protocols'                    => 'TLSv1.2,TLSv1.1,TLSv1',
    'ssl.protocol'                             => 'TLS',
    'ssl.provider'                             => '',
    'ssl.cipher.suites'                        => '',
    'ssl.endpoint.identification.algorithm'    => '',
    'ssl.keymanager.algorithm'                 => 'SunX509',
    'ssl.trustmanager.algorithm'               => 'PKIX',
  }

  # 0.9.0.0 has a new producer
  # hhttp://kafka.apache.org/documentation.html#producerconfigs
  $producer_new_config_defaults = {
    'bootstrap.servers'                        => '',
    'key.serializer'                           => '',
    'value.serializer'                         => '',
    'acks'                                     => '1',
    'buffer.memory'                            => '33554432',
    'compression.type'                         => 'none',
    'retries'                                  => '0',
    'batch.size'                               => '16384',
    'client.id'                                => '',
    'connections.max.idle.ms'                  => '540000',
    'linger.ms'                                => 0,
    'max.block.ms'                             => '60000',
    'max.request.size'                         => '1048576',
    'partitioner.class'                        => 'org.apache.kafka.clients.producer.internals.DefaultPartitioner',
    'receive.buffer.bytes'                     => '32768',
    'request.timeout.ms'                       => '30000',
    'send.buffer.bytes'                        => '131072',
    'timeout.ms'                               => '30000',
    'block.on.buffer.full'                     => false,
    'max.in.flight.requests.per.connection'    => '5',
    'metadata.fetch.timeout.ms'                => '60000',
    'metadata.max.age.ms'                      => '300000',
    'metric.reporters'                         => '',
    'metrics.num.samples'                      => '2',
    'metrics.sample.window.ms'                 => '30000',
    'reconnect.backoff.ms'                     => '50',
    'retry.backoff.ms'                         => '100	',
    'security.protocol'                        => 'PLAINTEXT',
    'sasl.kerberos.service.name'               => '',
    'sasl.kerberos.kinit.cmd'                  => '/usr/bin/kinit',
    'sasl.kerberos.min.time.before.relogin'    => '60000',
    'sasl.kerberos.ticket.renew.jitter'        => '0.05',
    'sasl.kerberos.ticket.renew.window.factor' => '0.8',
    'ssl.key.password'                         => '',
    'ssl.keystore.location'                    => '',
    'ssl.keystore.password'                    => '',
    'ssl.keystore.type'                        => 'JKS',
    'ssl.truststore.location'                  => '',
    'ssl.truststore.password'                  => '',
    'ssl.truststore.type'                      => 'JKS',
    'ssl.enabled.protocols'                    => 'TLSv1.2,TLSv1.1,TLSv1',
    'ssl.protocol'                             => 'TLS',
    'ssl.provider'                             => '',
    'ssl.cipher.suites'                        => '',
    'ssl.endpoint.identification.algorithm'    => '',
    'ssl.keymanager.algorithm'                 => 'SunX509',
    'ssl.trustmanager.algorithm'               => 'PKIX',
  }
}
