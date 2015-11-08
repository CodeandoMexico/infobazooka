require File.expand_path '../spec_helper.rb', __FILE__
require File.expand_path '../../lib/adapters/adapter.rb', __FILE__
require File.expand_path '../../lib/adapters/infomex/adapter.rb', __FILE__


describe "Infomex" do

  it "should post an information request" do
    infomex = Bazooka::Adapter.fetch('gobierno-federal')
    infomex.auth(username: 'infobazooka',  password: 'iXR/eRVCRK6pwXAePQ4VZ7(%')
    infomex.publish({
      user: {
        name: 'Test',
        last_name: ['apellido', 'apellido']
      },
      petition: {
        type: 'public',
        dependency: '16',
        text: <<-TEXT
    En atención al principio de máxima publicidad solicito la base o bases de datos que alimenta(n) la plataforma:http://tramites.semarnat.gob.mx/index.php/consulta-tu-tramite
     Aludiendo a los principios de gobierno abierto, si estas bases de datos estuviesen en formato de propietario o cerrado, solicito que se me haga entrega de las mismas en algún formato abierto o libre, por ejemplo: csv, json, xml, sql Los archivos deberán ser entregados por medios electrónicos y contener por lo menos la información presentada en http://tramites.semarnat.gob.mx/index.php/consulta-tu-tramite/ incluyendo los Identificadores únicos que utilicen los sistemas para identificar y relacionar los datos. Solicito se me incluya también cualquier tabla o campo adicional no visibles en la  pagina http://tramites.semarnat.gob.mx/index.php/consulta-tu-tramite, que formen parte de la base o el conjunto de bases de datos que utilice el sitio.
    En caso de contener datos personales se deberá entregar versión pública de la base o bases de datos solicitadas. Gracias
    TEXT
      }
    })
  end
end