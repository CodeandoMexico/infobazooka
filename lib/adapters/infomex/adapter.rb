Bazooka::Adapter.register('gobierno-federal') do
  # iXR/eRVCRK6pwXAePQ4VZ7(%
  self.load_config! File.dirname(__FILE__)+'/config.yml'
  self.full_name = 'Gobierno Federal'

  def initialize
    super
    @agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end


  def publish params
    page = @agent.get('https://www.infomex.org.mx/gobiernofederal/solicitudInformacion/nuevaSolicitud.action')
    form = page.form('frmRecInformacion')

    form.cboTipoSolicitud = self.class.config('kinds')[params[:petition][:type]]
    form.field_with(name: 'solicitud.UsDes').value = params[:petition][:text]
    form.field_with(name: 'solicitud.UsDat').value = params[:petition][:extra] if params[:petition][:extra]
    form.field_with(name: 'cboDependencia').value = params[:petition][:dependency]
    form.checkbox_with(name: 'chkDomicilioExt').check

    user = params[:user]
    form.radiobuttons_with(name: 'tipoPersona')[1].check
    form.field_with(name: 'solicitud.usNombre').value = user[:name]
    form.field_with(name: 'solicitud.usApepat').value = user[:last_name].first
    form.field_with(name: 'solicitud.usApemat').value = user[:last_name].last
    form.field_with(name: 'solicitud.usCalle').value = 'Avenida Siempreviva'
    form.field_with(name: 'solicitud.usNumext').value = '42'
    form.field_with(name: 'cboPais').value = '189' # Tuvalú

    result = @agent.submit(form, form.buttons_with(id: 'aceptar').first)
    link = result.at_css('.MAESTRO_TDETIQUETA a')
    return link.attr('onclick').scan(%r{(\d+)/(\d+)}).flatten.join
  end


  def register

  end


  def auth (credentials)
    res = HTTParty.post 'https://www.infomex.org.mx/gobiernofederal/loginInfomexSolictiante.action', body: {
      login: credentials[:username],
      password: credentials[:password]
    }, verify: false

    body = res.body
    if res.body =~ /Solicitante:/
      ssid = res.headers['Set-Cookie'].split(';').first.split('=').last
      cookie = Mechanize::Cookie.new domain: '.infomex.org.mx', name: 'JSESSIONID', value: ssid, path: '/gobiernofederal/'
      @agent.cookie_jar.add cookie
    else
      puts res.body
      raise 'invalido'
    end
  end
end

