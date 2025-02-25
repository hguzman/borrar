require 'bundler/setup'
require 'mechanize'
require 'nokogiri'

def pagina_incio(agent)
  page = agent.get('https://certificados.supernotariado.gov.co/certificado')
  jsession = agent.cookies.find { |c| c.name == 'JSESSIONID' }&.value
  view_state = page.at("input[name='javax.faces.ViewState']")&.attr('value')

  [agent, page, jsession, view_state]
end

def pide_login(agent, view_state)
  login_url = 'https://certificados.supernotariado.gov.co/certificado/inicio.snr'
  headers = {
    'User-Agent' => 'Mozilla/5.0',
    'Faces-Request' => 'partial/ajax',
    'X-Requested-With' => 'XMLHttpRequest'
  }
  data = {
    'javax.faces.partial.ajax' => 'true',
    'javax.faces.source' => 'j_idt15',
    'javax.faces.partial.execute' => '@all',
    'javax.faces.partial.render' => 'modalLogin',
    'j_idt15' => 'j_idt15',
    'j_idt30' => 'j_idt30',
    'javax.faces.ViewState' => view_state
  }

  page = agent.post(login_url, data, headers)
  jsession = agent.cookies.find { |c| c.name == 'JSESSIONID' }&.value

  xml = Nokogiri::XML(page.body)
  view_state = xml.xpath("//update[@id='javax.faces.ViewState']").text
  [agent, page, jsession, view_state]
end

def manda_login(agent, page, view_state)
  xml = Nokogiri::XML(page.body)
  form_html = xml.xpath("//update[@id='modalLogin']").text
  form_page = Nokogiri::HTML(form_html)
  form_action = form_page.at('form')&.attr('action')

  # Colocar en una variable de entorno
  credenciales = 'NI900835628,Melachu_01;CC72230311,Melachu_3527;CC22524415,Melachu_01'
  user = credenciales.split(';').sample

  usuario, password = user.split(',')
  puts "USUARIO: #{usuario}"

  headers = {
    'User-Agent' => 'Mozilla/5.0',
    'Faces-Request' => 'partial/ajax',
    'X-Requested-With' => 'XMLHttpRequest'
  }
  url = "https://certificados.supernotariado.gov.co#{form_action}"
  page = agent.post(
    url, {
      'javax.faces.partial.ajax' => 'true',
      'javax.faces.source' => 'formLogin:btnIngresarLogin',
      'javax.faces.partial.execute' => '@all',
      'javax.faces.partial.render' => 'formLogin',
      'formLogin:btnIngresarLogin' => 'formLogin:btnIngresarLogin',
      'formLogin' => 'formLogin',
      'formLogin:inpUserLogin' => usuario,
      'formLogin:inpPassLogin' => password,
      'javax.faces.ViewState' => view_state
    },
    headers
  )

  [agent, page]
end

def get_menu(agent)
  page = agent.get('https://certificados.supernotariado.gov.co/certificado')
  view_state = page.at("input[name='javax.faces.ViewState']")&.attr('value')
  [agent, page, view_state]
end

def opcion_general(agent)
  url = 'https://certificados.supernotariado.gov.co/certificado/portal/business/main-queries-advanced.snr'
  page = agent.get(url)
  view_state = page.at("input[name='javax.faces.ViewState']")&.attr('value')
  [agent, page, view_state]
end

def solicitar(agent, view_state)
  url = 'https://certificados.supernotariado.gov.co/certificado/portal/business/main-queries-advanced.snr'
  headers = {
    'User-Agent' => 'Mozilla/5.0',
    'Faces-Request' => 'partial/ajax',
    'X-Requested-With' => 'XMLHttpRequest'
  }
  data = {
    'javax.faces.partial.ajax' => 'true',
    'javax.faces.source' => 'formQueries:j_idt42',
    'javax.faces.partial.execute' => '@all',
    'javax.faces.partial.render' => 'formQueries',
    'formQueries:j_idt42' => 'formQueries:j_idt42',
    'formQueries' => 'formQueries',
    'formQueries:listaTipoResultado_focus' => '',
    'formQueries:listaTipoResultado_input' => 'CI1',
    'javax.faces.ViewState' => view_state
  }

  page = agent.post(url, data, headers)
  xml = Nokogiri::XML(page.body)
  view_state = xml.xpath("//update[@id='javax.faces.ViewState']").text
  [agent, page, view_state]
end

def buscar(agent, view_state, cedula)
  url = 'https://certificados.supernotariado.gov.co/certificado/portal/business/main-queries-advanced.snr'
  headers = {
    'User-Agent' => 'Mozilla/5.0',
    'Faces-Request' => 'partial/ajax',
    'X-Requested-With' => 'XMLHttpRequest'
  }
  data = {
    'javax.faces.partial.ajax' => 'true',
    'javax.faces.source' => 'formQueries:j_idt87',
    'javax.faces.partial.execute' => '@all',
    'javax.faces.partial.render' => 'formQueries modalMedioPago modalResultadoTransaccion',
    'formQueries:j_idt87' => 'formQueries:j_idt87',
    'formQueries' => 'formQueries',
    'formQueries:listaTipoResultado_focus' => '',
    'formQueries:listaTipoResultado_input' => 'CI1',
    'formQueries:j_idt55_focus' => '',
    'formQueries:j_idt55_input' => '1',
    'formQueries:j_idt58' => cedula,
    'javax.faces.ViewState' => view_state
  }

  page = agent.post(url, data, headers)
  [agent, page]
end

# Inicia el programa
# def hanler(event:, context)
# Aqui colocas la logica para extraer la cedula del event
# colocar la cedula en una variable

agent = Mechanize.new

agent, page, jsession, view_state = pagina_incio(agent)
puts "ViewState pagina inicio: #{view_state}"
# sleep(2)

agent, page, jsession, view_state = pide_login(agent, view_state)
puts "ViewState pide login: #{view_state}"
# sleep(2)

agent, page = manda_login(agent, page, view_state)
puts "ViewState manda login: #{view_state}"
# sleep(2)

agent, page, view_state = get_menu(agent)
puts "ViewState get menu: #{view_state}"
# sleep(2)

agent, page, view_state = opcion_general(agent)
puts "ViewState opcion menu: #{view_state}"
# sleep(2)

agent, page, view_state = solicitar(agent, view_state)
puts "ViewState solicitar: #{view_state}"
# sleep(2)
# puts page.body

agent, page = buscar(agent, view_state, '72230311')
# puts page.body

doc = Nokogiri::XML(page.body)

cdata_content = doc.at_xpath("//update[@id='modalResultadoTransaccion']").text
html_doc = Nokogiri::HTML(cdata_content)
tbody = html_doc.at('tbody#formModalResultado\\:consultas_data')
rows = tbody.search('tr')
titles = ['N°', 'Ciudad', 'Documento', 'Direccion', 'Tipo']
respuesta = ''
rows.each do |row|
  respuesta << "| Campo | Valor |\n"
  respuesta << "| --- | --- |\n"
  cells = row.search('td').map(&:text)
  cells.each_with_index do |field, index|
    respuesta << "| #{titles[index]} | #{field} |\n"
  end
  respuesta << "\n"
end

annotation = {
  title: 'Propiedades',
  description: respuesta,
  event_date_at: Time.now.to_i
}
puts annotation

# Codigo para incluir la anotacion en el json de la maquina de estado
# llamado a la maquina de estado
