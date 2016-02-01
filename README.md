# Puppet Kafka

[![Build Status](https://travis-ci.org/intelliad-media/puppet-kafka.svg?branch=master)](https://travis-ci.org/intelliad-media/puppet-kafka)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with kafka](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kafka](#beginning-with-kafka)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Kafka Module to install broker and multiple MirrorMaker instances with 0.9 Support.
The Module use native Service provider such like systemd or upstart.

## Setup

### Setup Requirements

The Module requires the following puppet modules:
 * puppet-stdlib
 * puppet-archive

### Beginning with kafka

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

### Basic Usage


```puppet
class { 'kafka':
  java_install => true,
  version => '0.9.0.0',
  scala_version => '2.11',
  service_provider => 'systemd',
}

class { 'kafka::broker':
  service_environment => {
    'KAFKA_HEAP_OPTS' => '-Xmx2G -Xms1G',
  }
  config => {
    'broker.id' => '1',
    'zookeeper.connect' => 'localhost:2181',
  }
}

kafka::mirror { 'aws-to-dc1':
  service_environment => {
    'KAFKA_HEAP_OPTS' => '-Xmx1G -Xms512M',
  },
  new_consumer => true,
  consumer_config => {
  ...
  }
  producer_config => {
  ...
  }
}

```

## Reference

### Classes
See manifests for available parameter

* `kafka`: Set default parameters or ensure kafka directories and user/group to absent
* `kafka::broker`: Install Kafka broker and config

### Defines
See manifests for available parameter

* `kafka::mirror`: Define a new kafka mirror instance

## Limitations

This module is tested with the following Kafka versions.
  * 0.9.0.0
  * It should also work with 0.8.x, but its still not tested.

This module is tested on the following platforms:
  * Ubuntu 14.04
  * It should also work with other platforms with systemd and upstart provider, but its still not tested.

It is tested with the OSS version of Puppet only.
