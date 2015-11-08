require 'mechanize'
require 'httparty'

module Bazooka

  module Adapter
    # Un adaptador se encarga de la comunicación entre este API y
    # una institución de acceso a la información.

    # Los adaptadores que se han registrado para ser utilizados
    # @private
    @@registered = {}

    # Registra un adaptador bajo un slug
    #
    # @param  nombre [String] El slug de un adaptador, i.e. `gobierno-federal`
    # @yield [GenericAdapter] Una clase anónima que extiende GenericAdapter
    def self.register nombre, &block
      @@registered[nombre] = Class.new(GenericAdapter) do
        self.id = nombre
        self.class_eval(&block)
      end
    end

    # Obtiene uno de los adaptadores registrados
    #
    # @param  nombre [String] El slug del adaptador
    # @return [GenericAdapter]
    def self.fetch nombre
      return @@registered[nombre].new
    end

    # Obtiene todos los adaptadores registrados
    # @return [Array]
    def self.registered
      @@registered
    end
  end
end