require 'bundler/setup'

require 'httparty'
require 'nokogiri'

BASE_URL = 'https://certificados.supernotariado.gov.co'
SESSION_URL = "#{BASE_URL}/certificado/portal/business/main-queries-advanced.snr"

response = HTTParty.get(BASE_URL, headers: { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:135.0) Gecko/20100101 Firefox/135.0" })

# Extraer cookies de la sesión
cookies = response.headers['set-cookie']
jsession_id = cookies[/JSESSIONID=([^;]+)/, 1] if cookies

# puts cookies

# Extraer javax.faces.ViewState con Nokogiri
doc = Nokogiri::HTML(response.body)
view_state = doc.at('input[name="javax.faces.ViewState"]')&.[]('value')

raise "No se pudo obtener JSESSIONID o ViewState" unless jsession_id && view_state

puts view_state
# puts jsession_id

headers = {
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:135.0) Gecko/20100101 Firefox/135.0",
  "Accept" => "application/xml, text/xml, */*; q=0.01",
  "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
  "Faces-Request" => "partial/ajax",
  "X-Requested-With" => "XMLHttpRequest",
  "Cookie" => "JSESSIONID=#{jsession_id}",
  "Origin" => BASE_URL,
  "Referer" => BASE_URL,
}

# Cuerpo de la solicitud
body = {
  "javax.faces.partial.ajax" => "true",
  "javax.faces.source" => "formQueries:j_idt87",
  "javax.faces.partial.execute" => "@all",
  "javax.faces.partial.render" => "formQueries+modalMedioPago+modalResultadoTransaccion",
  "formQueries:j_idt87" => "formQueries:j_idt87",
  "formQueries" => "formQueries",
  "formQueries:listaTipoResultado_focus" => "",
  "formQueries:listaTipoResultado_input" => "CI1",
  "formQueries:j_idt55_focus" => "",
  "formQueries:j_idt55_input" => "1",
  "formQueries:j_idt58" => "22524415",
  "javax.faces.ViewState" => view_state
}

# Enviar la solicitud POST
post_response = HTTParty.post(SESSION_URL, headers: headers, body: URI.encode_www_form(body))

# puts post_response.body

# Extraer el nuevo ViewState de la respuesta XML
xml_doc = Nokogiri::XML(post_response.body)
new_view_state = xml_doc.at('update[id="javax.faces.ViewState"]')&.content

raise "No se pudo obtener el nuevo ViewState" unless new_view_state

puts "NUEVO #{new_view_state}"

