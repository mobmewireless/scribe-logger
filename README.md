## Description

The project MobME Infrastructure Scribe provides scribe logging capabilities to projects, taking in a hive schema as the log template.

## Install

Scribe is packaged as a ruby gem, to be easily used. To install, follow the steps below:

  $ gem install scribe-logger

## Usage

    require 'scribe-logger'
    scribe = Scribe.loggers(:schema_uri => "http://s1.mobme.in/appsuite-vodafone-in/schema.yml")
    scribe.log_visit(:mobile => "8943011156")
    scribe.log_event(:event => "sub", :mobile => "8943011156")

Scribe.loggers take in the following options as a ruby hash:
:schema_uri [string]
:scribe_host [string] = Defaut: localhost
:scribe_port [integer] = Default: 1464
:evented [boolean] = Default: false

## Evented Scribe
 
Scribe supports evented scribing [EventMachine Support], to be used in an event driven environment.

Points to be noted to enable Evented Scribe
1. Set :evented to true in Scribe.logger
2. Run your entire application inside a Fiber
3. require 'fiber'

Example code:

require 'scribe-logger'
require 'fiber'

scribe = Scribe.loggers(:schema_uri => "http://s1.mobme.in/appsuite-vodafone-in/schema.yml", :evented => true)

EM.run do
  Fiber.new do
    scribe.log_visit(:mobile => "8943011156")
  end.resume
end


