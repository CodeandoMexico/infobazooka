module Bazooka

  module Adapter

    @@adapters = {}

    def self.register nombre, &block;
      @@registered[nombre] = Class.new(AdapterMethods) do
        self.name = nombre
        self.class_eval(&block)
      end
    end

    def self.get nombre
      cfg = @@adapters[nombre]
      adapter = Adapter.new
      adapter.instance_eval(cfg[:config]);
      return adapter
    end


    def self.registered
      @@registered.map {|adapter|
        [adapter.name, adapter.dependencies]
      }
    end


    class AdapterMethods
      @@config = {}

      def initialize
        @agent = Mechanize.new
      end


      def self.name= name
        @@name = name
      end

      def self.base= base
        @@base = base
      end

      def name
        @@name
      end


      def dependencies
        @@config['dependencies']
      end


      def self.load_config! file
        self.class_variable_set '@@config', YAML.load(File.read(file))
      end

      def self.config key
        self.class_variable_get "@@#{key}"
      end
    end
  end

end