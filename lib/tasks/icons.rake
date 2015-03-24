
namespace :icons do

  task :svg => :environment do
    filepath = '././public/icons/'
    hash = []
    output = File.new(filepath + 'icons.svg', 'w')
    output.puts '<?xml version="1.0" encoding="utf-8"?>'
    output.puts '<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
    output.puts '<svg display="none" width="0" height="0" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<defs>'

    Dir.entries(filepath).each do |file|
      puts file
      if file != 'icons.svg' && file != '.' && file != '..'
        puts 'Parsing ' + file
        @doc = Nokogiri::XML(File.open(filepath + file))

        title = file.split('.')[0]
        svg = @doc.css 'svg'

        width = svg.attribute('width')
        height = svg.attribute('height')
        view_box = svg.attribute('viewBox')

        # puts 'Title: ' + title
        content = svg.inner_html
        symbol = "<symbol id='icon-#{title}' width='#{width}' height='#{height}' viewBox='#{view_box}'><title>#{title}</title>#{content}</symbol>"
        output.puts symbol

        object = {}
        object['id'] = title
        object['width'] = width.value
        object['height'] = height.value
        hash << object
      end
    end

    output.puts '</defs>
</svg>'
    output.close

    json_output = File.new(filepath + 'icons.json', 'w')
    json_output.puts hash.to_json
    json_output.close
  end

end