# coding: utf-8

require "json"

module M_JF
  class M_Config
    @@conf_filename = "config.json"

    def initialize()
      @args = {}
      update_config
    end

    def args
      @args
    end

    def args=(args)
      @args = args
    end

    def set(k, v)
      @args[k] = v
      sync_conf
    end

    def update_config
      conf = JSON.parse File.read @@conf_filename
      @args.each do |k, v|
        conf[k] = v
      end
      @args = conf
    end

    def sync_conf
      File.open(@@conf_filename, "w") do |f|
        f.write JSON.pretty_generate @args
      end
    end

    def print_config
      if File.exist? @@conf_filename
        dict = JSON.parse File.read @@conf_filename
        dict.each do |k, v|
          if k.length < 20
            k = k + " " * (20 - k.length)
          end
          puts "#{k} => #{v}"
        end
      end
    end
  end
end
