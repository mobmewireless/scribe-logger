$: << File.expand_path("../../vendor/scribe-thrift/gen-rb", __FILE__)
$current_path = File.dirname(File.expand_path(__FILE__))
require "#{$current_path}/scribe_logger/version"

module Scribe
  require 'active_support'
  require 'active_support/core_ext/kernel'
  require 'active_record'

  silence_warnings do
    require 'activerecord-hive-adapter'
  end

  require 'active_record/connection_adapters/hive_adapter'
  require 'thrift_client'
  require 'thrift_client/event_machine' if defined? EventMachine
  begin
    require 'active_support/time'
    require 'active_support/core_ext/hash'
  rescue LoadError
    require 'active_support'
  end
  require 'open-uri'
  require 'uuid'

  require "#{File.expand_path("../../vendor/scribe-thrift/gen-rb", __FILE__)}/scribe"
  require "#{$current_path}/scribe_logger/scribe_connection"
  require "#{$current_path}/scribe_logger/scribe"
end
