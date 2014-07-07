module Scribe
  class << self

    @@default_config = {
        :scribe_host => '127.0.0.1',
        :scribe_port => 1464,
        :noscribe => false, # Set this to true if you dont want to log to scribe-logger.
        :tzone => 'Kolkata',
        :evented => false,
    }

    def loggers(config)
      config = merge_defaults(config)
      scribe_connection = connected_scribe(config)
      database = YAML.load(open(config[:schema_uri]).read)
      hostname = IO.popen('hostname').read.strip
      loggers = database['tables'].map do |table_name, table_def|
        columns = []
        table_def['columns'].each do |col_name, col_def|
          args = [col_name] + col_def.values_at('default', 'type', 'partition')
          columns << ActiveRecord::ConnectionAdapters::HiveColumn.new(*args)
        end
        options = {
            :database => config[:database] || database['name'],
            :table => table_name,
            :columns => columns,
            :noscribe => config[:noscribe],
            :tzone => config[:tzone],
            :writes_to_legacy_scribe => database['writes_to_legacy_scribe'] || false,
            :hostname => hostname,
        }
        logger_name = "log_#{table_name.singularize.underscore}"
        logger_proc = make_logger_proc(scribe_connection, options)
        [logger_name, logger_proc]
      end
      Module.new {
        loggers.each do |name, proc|
          define_method(name, proc)
          module_function(name)
        end
      }
    end

    private
    def merge_defaults(config)
      @@default_config.merge(config.symbolize_keys)
    end

    def connected_scribe(config)
      scribe_connection = ScribeConnection.new("#{config[:scribe_host]}:#{config[:scribe_port]}", config[:evented])
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          if forked
            scribe_connection.reconnect!
          end
        end
      end
      scribe_connection
    end

    def make_logger_proc(scribe_connection, options)
      database = options[:database]
      table = options[:table]
      partitions = options[:columns].select { |c| c.partition? }
      columns = options[:columns].reject { |c| c.partition? }
      Proc.new do |*args|
        obj, hash = args
        params =
            if obj.respond_to?(:to_scribe)
              obj.to_scribe.merge(hash || {})
            elsif obj.kind_of?(Hash)
              obj
            else
              hash || {}
            end
        logstr = columns.map do |c|
          val = params[c.name.to_sym] || c.realized_default
          val = if (val.kind_of?(DateTime) || val.kind_of?(Time))
                  val.in_time_zone(options[:tzone]).strftime("%Y-%m-%d %H:%M:%S")
                elsif val.kind_of?(Date)
                  val.to_datetime.in_time_zone(options[:tzone]).strftime("%Y-%m-%d")
                elsif c.name.to_sym == :uuid
                  UUID.generate
                elsif c.name.to_sym == :client_hostname
                  options[:hostname]
                else
                  val
                end
        end.join("\t")
        logstr << "\n"
        partition_spec = partitions.map do |p|
          val = params[p.name.to_sym] || p.realized_default || "nil"
          val = if val.kind_of?(Date)
                  # convert date to string in given timezone relative to current time.
                  full_datestr = val.strftime("%Y-%m-%d") + DateTime.now.strftime(" %H:%M:%S")
                  DateTime.
                      strptime(full_datestr, "%Y-%m-%d %H:%M:%S").
                      in_time_zone(options[:tzone]).
                      strftime("%Y-%m-%d")
                else
                  val
                end
          "#{p.name}=#{val}"
        end.join("/")
        category = options[:writes_to_legacy_scribe] ? table : "#{database}.db/#{table}/#{partition_spec}"
        if true == options[:noscribe]
          puts "[scribe] #{category}: #{logstr}"
        else
          scribe_connection.log(category, logstr)
        end
      end
    end

  end
end
