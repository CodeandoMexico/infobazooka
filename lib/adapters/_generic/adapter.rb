module Bazooka
  module Adapter

    class GenericAdapter
      # La interfaz a implementar de un adaptador

      @@config = {}

      # Crea un adaptador nuevo
      def initialize
        @agent = ::Mechanize.new
      end

      # El adaptador implementa `auth` función para iniciar sesión
      #
      # @param  credentials [Hash]
      def auth credentials
        raise NotImplementedError.new
      end

      # El adaptador implementa `publish` para crear una solicitud nueva
      #
      # @param  message [Hash]
      # @return [String] El folio de la solicitud creada
      def publish message
        raise NotImplementedError.new
      end

      # Class Methods
      class << self

        def id= id
          @@id = id
        end

        def id
          self.class_variable_get("@@id")
        end

        def full_name= name
          @@name = name
        end

        def full_name
          self.class_variable_get("@@name")
        end

        # Regresa los sujetos obligados
        # @return [Hash]
        def dependencies
          self.config('dependencies')
        end

        # Carga la configuración en YAML
        #
        # @param  file [String] El path al archivo de configuración
        def load_config! file
          cfg = YAML.load(File.read(file))
          self.class_variable_set('@@config', cfg)
        end

        # Obtiene un valor de la configuración cargada
        #
        # @param  key [String] La llave que estamos buscando
        def config key
          self.class_variable_get("@@config")[key]
        end
      end
    end

  end
end