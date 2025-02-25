require 'nokogiri'

xml_data = <<-XML
<partial-response>
  <changes>
    <update id="modalLogin">
      <![CDATA[<form action="/certificado/login">
        <input type="text" name="user">
        <input type="password" name="password">
      </form>]]>
    </update>
  </changes>
</partial-response>
XML

xml_data = File.read('archivo.xml')

doc = Nokogiri::XML(xml_data)
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

# puts respuesta

annotation = {
  title: 'Propiedades',
  description: respuesta,
  event_date_at: Time.now.to_i
}
puts annotation
