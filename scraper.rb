require 'bundler/setup'

require 'mechanize'

agent = Mechanize.new

page = agent.get('https://certificados.supernotariado.gov.co/certificado')

# puts page.body

jsession_id = agent.cookies.find { |c| c.name == "JSESSIONID" }&.value

# Obtener el ViewState desde la página
view_state = page.at("input[name='javax.faces.ViewState']")&.attr("value")

puts "JSESSIONID: #{jsession_id}"
puts "ViewState: #{view_state}"

# Construir la URL con el JSESSIONID
post_url = "https://certificados.supernotariado.gov.co/certificado/inicio.snr;jsessionid=#{jsession_id}"

# Definir los headers adicionales
headers = {
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:135.0) Gecko/20100101 Firefox/135.0",
  "Accept" => "application/xml, text/xml, */*; q=0.01",
  "Accept-Language" => "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
  "Accept-Encoding" => "gzip, deflate, br, zstd",
  "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
  "Faces-Request" => "partial/ajax",
  "X-Requested-With" => "XMLHttpRequest",
  "Origin" => "https://certificados.supernotariado.gov.co",
  "Connection" => "keep-alive"
}

# Definir los parámetros que se enviarán en el cuerpo del POST
post_data = {
  "javax.faces.partial.ajax" => "true",
  "javax.faces.source" => "j_idt15",
  "javax.faces.partial.execute" => "@all",
  "javax.faces.partial.render" => "modalLogin",
  "j_idt15" => "j_idt15",
  "j_idt30" => "j_idt30",
  "javax.faces.ViewState" => view_state
}

# Realizar la petición POST con Mechanize
page = agent.post(post_url, post_data, headers)

# Mostrar la respuesta
puts "Respuesta del POST:"
puts page.body

xml = Nokogiri::XML(page.body)
new_view_state = xml.xpath("//update[@id='javax.faces.ViewState']").text

puts "Nuevo ViewState: #{new_view_state}"
# form = page.form_with(id: 'formLogin')
# puts form
# Extraer el formulario de login

form_html = xml.xpath("//update[@id='modalLogin']").text
form_page = Nokogiri::HTML(form_html)

# Obtener la acción del formulario (ruta donde se debe enviar)
form_action = form_page.at("form")&.attr("action")
# puts form_action

usuario = "NI900835628"  # Reemplazar con el usuario real
password = "Melachu_01"  # Reemplazar con la contraseña real

# Enviar el formulario de login
login_url = "https://certificados.supernotariado.gov.co#{form_action}"

login_response = agent.post(login_url, {
  "formLogin" => "formLogin",
  "formLogin:inpUserLogin" => usuario,
  "formLogin:inpPassLogin" => password,
  "javax.faces.ViewState" => new_view_state,
  "formLogin:btnIngresarLogin" => "Ingresar"
}, {
  "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8"
})

# Mostrar la respuesta después del login
puts "Respuesta después del login:"
# puts login_response.body
xml = Nokogiri::XML(login_response.body)
new_view_state = xml.xpath("//update[@id='javax.faces.ViewState']").text

puts "Nuevo ViewState después del login: #{new_view_state}"

advanced_queries_url = "https://certificados.supernotariado.gov.co/certificado/portal/business/main-queries-advanced.snr"

advanced_page = agent.get(advanced_queries_url, [], advanced_queries_url, {
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:135.0) Gecko/20100101 Firefox/135.0",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  "Accept-Language" => "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
  "Accept-Encoding" => "gzip, deflate, br, zstd",
  "Connection" => "keep-alive"
})

puts "Página de consultas avanzadas obtenida correctamente"
puts advanced_page.body

# Realizar la petición POST para obtener los resultados avanzados
post_url = "https://certificados.supernotariado.gov.co/certificado/portal/business/main-queries-advanced.snr"

# Extraer el nuevo ViewState desde la página de consultas avanzadas
advanced_page_nokogiri = Nokogiri::HTML(advanced_page.body)
new_view_state = advanced_page_nokogiri.at("input[name='javax.faces.ViewState']")&.attr("value")

# Definir los headers
headers = {
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:135.0) Gecko/20100101 Firefox/135.0",
  "Accept" => "application/xml, text/xml, */*; q=0.01",
  "Accept-Language" => "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
  "Accept-Encoding" => "gzip, deflate, br, zstd",
  "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
  "Faces-Request" => "partial/ajax",
  "X-Requested-With" => "XMLHttpRequest",
  "Origin" => "https://certificados.supernotariado.gov.co",
  "Connection" => "keep-alive"
}

# Definir los datos del POST
post_data = {
  "javax.faces.partial.ajax" => "true",
  "javax.faces.source" => "formQueries:j_idt42",
  "javax.faces.partial.execute" => "@all",
  "javax.faces.partial.render" => "formQueries",
  "formQueries:j_idt42" => "formQueries:j_idt42",
  "formQueries" => "formQueries",
  "formQueries:listaTipoResultado_focus" => "",
  "formQueries:listaTipoResultado_input" => "CI1",
  "javax.faces.ViewState" => new_view_state
}

# Enviar la petición POST
response = agent.post(post_url, post_data, headers)

# Mostrar la respuesta del servidor
puts "Respuesta de la consulta avanzada:"
puts response.body

# -------------------

# Extraer el nuevo ViewState desde la respuesta anterior
xml_response = Nokogiri::XML(response.body)
latest_view_state = xml_response.xpath("//update[@id='javax.faces.ViewState']").text

# Validar que el ViewState no esté vacío
if latest_view_state.nil? || latest_view_state.strip.empty?
  puts "Error: No se pudo obtener un nuevo ViewState. La sesión pudo haber expirado."
  exit
end

# URL de la última petición POST
final_post_url = "https://certificados.supernotariado.gov.co/certificado/portal/business/main-queries-advanced.snr"

# Extraer el ViewState más reciente desde la página de consulta avanzada
final_page_nokogiri = Nokogiri::HTML(response.body)
latest_view_state = final_page_nokogiri.at("input[name='javax.faces.ViewState']")&.attr("value")

# Definir los headers
final_headers = {
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:135.0) Gecko/20100101 Firefox/135.0",
  "Accept" => "application/xml, text/xml, */*; q=0.01",
  "Accept-Language" => "es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3",
  "Accept-Encoding" => "gzip, deflate, br, zstd",
  "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
  "Faces-Request" => "partial/ajax",
  "X-Requested-With" => "XMLHttpRequest",
  "Origin" => "https://certificados.supernotariado.gov.co",
  "Connection" => "keep-alive"
}

# Definir los datos del POST
final_post_data = {
  "javax.faces.partial.ajax" => "true",
  "javax.faces.source" => "formQueries:j_idt87",
  "javax.faces.partial.execute" => "@all",
  "javax.faces.partial.render" => "formQueries modalMedioPago modalResultadoTransaccion",
  "formQueries:j_idt87" => "formQueries:j_idt87",
  "formQueries" => "formQueries",
  "formQueries:listaTipoResultado_focus" => "",
  "formQueries:listaTipoResultado_input" => "CI1",
  "formQueries:j_idt55_focus" => "",
  "formQueries:j_idt55_input" => "1",
  "formQueries:j_idt58" => "72230311",  # Número de identificación (ajustar según corresponda)
  "javax.faces.ViewState" => latest_view_state
}

# Enviar la última petición POST
final_response = agent.post(final_post_url, final_post_data, final_headers)

# Mostrar la respuesta del servidor
puts "Respuesta de la última consulta:"
puts final_response.body

