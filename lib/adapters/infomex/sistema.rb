module Bazooka
  module Infomex
    class Sistema
      # Un Sistema se encarga de la comunicación entre este API y
      # una institución de acceso a la información.

      # Los paths de esta versión de Infomex
      PATHS = {
        login:    'loginInfomexSolictiante.action',
        publish:  'solicitudInformacion/nuevaSolicitud.action',
        register: ''
      }

      # Los tipos de solicitudes
      KINDS = {
        public: "0",
        private: "1",
        correction: "2"
      }

      attr_reader :base, :name, :dependencies

      # Crea un adaptador nuevo
      #
      # @param  [Hash] config La configuración de este sistema
      # @option data [Symbol] :nombre El nombre para display
      # @option data [Symbol] :endpoint El url base de este sistema
      # @option data [Hash]   :dependencias La lista de dependencias de manera que `d[id] = "nombre"`
      def initialize config
        @agent = ::Mechanize.new
        @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

        @base = config[:endpoint]
        @name = config[:name]
        @dependencies = config[:dependencias]
      end

      # El adaptador implementa `auth` función para iniciar sesión
      #
      # @param  [Hash] credentials El set de credenciales del usuario
      # @option credentials [String] :username El nombre de usuario
      # @option credentials [String] :password El password del usuario
      def auth credentials
        body = {
          login: credentials[:username],
          password: credentials[:password]
        }

        res = HTTParty.post(endpoint(:login), {
          body: body,
          verify: false
        })

        if res.body =~ /Solicitante:/
          ssid = res.headers['Set-Cookie'].split(';').first.split('=').last
          cookie = Mechanize::Cookie.new domain: '.infomex.org.mx', name: 'JSESSIONID', value: ssid, path: '/gobiernofederal/'
          @agent.cookie_jar.add cookie
        else
          raise 'Credenciales inválidas'
        end
      end

      # Crea una solicitud nueva
      #
      # @param  [Hash] msg La solicitud a enviar
      # @option msg [Hash] :user Los detalles del usuario
      # @option :user [String] :name El nombre de pila del usuario
      # @option :user [Array]  :last_name La lista de apellidos del usuario
      # @option msg [Hash] :petition Los detalles de la solicitud
      # @option :petition [String] :type El tipo de solicitud (private, public, correction)
      # @option :petition [String] :text El texto de la solicitud
      # @option :petition [String] :extra El texto complementario de la solicitud
      # @option :petition [String] :dependency El ID del sujeto obligado
      # @return [String] El folio de la solicitud creada
      def publish msg
        page = @agent.get endpoint(:publish)
        form = page.form('frmRecInformacion')

        form.cboTipoSolicitud = KINDS[msg[:petition][:type]]
        form.field_with(name: 'solicitud.UsDes').value = msg[:petition][:text]
        form.field_with(name: 'solicitud.UsDat').value = msg[:petition][:extra] if msg[:petition][:extra]
        form.field_with(name: 'cboDependencia').value = msg[:petition][:dependency]
        form.checkbox_with(name: 'chkDomicilioExt').check

        user = msg[:user]
        form.radiobuttons_with(name: 'tipoPersona')[1].check
        form.field_with(name: 'solicitud.usNombre').value = user[:name]
        form.field_with(name: 'solicitud.usApepat').value = user[:last_name].first
        form.field_with(name: 'solicitud.usApemat').value = user[:last_name].last
        form.field_with(name: 'solicitud.usCalle').value = 'Avenida Siempreviva'
        form.field_with(name: 'solicitud.usNumext').value = '42'
        form.field_with(name: 'cboPais').value = '189' # Tuvalú

        result = @agent.submit(form, form.buttons_with(id: 'aceptar').first)
        link = result.parser.at_css('.MAESTRO_TDETIQUETA a')
        return link.attr('onclick').scan(%r{(\d+)/(\d+)}).flatten.join
      end

      private

      def endpoint action
        base + '/' + PATHS[action]
      end

    end
  end
end