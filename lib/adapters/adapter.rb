module Bazooka

  module Adapter

    @@registered = {}

    def self.register id, &block;
      @@registered[id] = Class.new(AdapterMethods) do
        self.id = id
        self.class_eval(&block)
      end
    end

    def self.fetch nombre
      return @@registered[nombre].new
    end


    def self.registered
      @@registered
    end


    class AdapterMethods
      @@config = {}

      # Crea un crawler nuevo
      def initialize
        @agent = ::Mechanize.new
      end

      def self.id= id
        @@id = id
      end

      def id
        self.class_variable_get("@@id")
      end

      def self.full_name= name
        @@name = name
      end

      def self.full_name
        self.class_variable_get("@@name")
      end

      # Regresa los sujetos obligados
      def self.dependencies
        self.config('dependencies')
      end

      def self.load_config! file
        self.class_variable_set '@@config', YAML.load(File.read(file))
      end

      def self.config key
        self.class_variable_get("@@config")[key]
      end
    end
  end

end