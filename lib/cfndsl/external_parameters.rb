module CfnDsl
  # Handles all external parameters
  class ExternalParameters
    extend Forwardable

    def_delegators :parameters, :fetch, :keys, :values, :each_pair

    attr_reader :parameters

    def initialize
      @parameters = {}
    end

    def set_param(k, v)
      parameters[k.to_sym] = v
    end

    def get_param(k)
      parameters[k.to_sym]
    end
    alias [] get_param

    def to_h
      parameters
    end

    def add_to_binding(bind, logstream)
      parameters.each_pair do |key, val|
        logstream.puts("Setting local variable #{key} to #{val}") if logstream
        bind.eval "#{key} = #{val.inspect}"
      end
    end

    def load_file(fname)
      format = File.extname fname
      case format
      when /ya?ml/
        params = YAML.load_file fname
      when /json/
        params = JSON.load File.read(fname)
      else
        raise "Unrecognized extension #{format}"
      end
      params.each { |key, val| set_param(key, val) }
    end
  end
end
