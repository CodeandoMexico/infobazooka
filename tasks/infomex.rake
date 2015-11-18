# encoding: utf-8

namespace :infomex do

  task :bundle do
    require 'rubygems'
    require 'bundler'

    Bundler.require :infomex
  end

  desc "Actualiza la lista de sistemas Infomex Disponibles"
  task sistemas: :bundle do
    require 'open-uri'
    require 'i18n'
    require 'yaml'

    base = 'http://www.proyectoinfomex.org.mx/'
    sujetos = {}

    I18n.enforce_available_locales = false

    def slug text
      I18n.transliterate(text).downcase.strip.gsub(/[^a-z\s]/, '').gsub(' ', '-')
    end

    index = Nokogiri::HTML(open(base+'index.php'))
    selector = '#Convenio_nav_treeNavigator > ul > li:nth-child(3) a[href^=index]'

    index.css(selector).each do |link|
      href = link.attr('href')
      source = base+href;
      nombre = link.text.gsub(/\s*Infomex\s*/, '').strip
      entidad = href.scan(/estado=(\d+)/).flatten.first.to_i
      entidad = 0 if entidad == 33

      info = Nokogiri::HTML(open(source))
      url_link = info.at_css('#Header1_nav_ctl a.mayusculas')

      sujetos[slug(nombre)] = {
        nombre: nombre,
        entidad: entidad,
        endpoint: url_link.attr('href'),
        dependencias: []
      }
    end

    app_path = File.expand_path(File.dirname(File.dirname(__FILE__)))
    path = app_path+'/data/sistemas.yaml'
    File.open(path, 'w') { |io| io << YAML.dump(sujetos) }
    puts "#{sujetos.values.count} sistemas guardados en #{path}"
  end

end