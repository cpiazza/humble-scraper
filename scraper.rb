require "HTTParty"
require 'open-uri'
require 'nokogiri'
require 'pry'

## Get all the archive links
archive_page = Nokogiri::HTML(URI.open("https://www.humblerecipes.com/archives.html"))

archive_links = archive_page.css('li.archive-list-item').map { |e| e.children.first.attributes["href"].value }

archive_links.each do |month_link|
  month_page = Nokogiri::HTML(URI.open(month_link))
  post_links = month_page.css('h3.entry-header').map { |e| e.children.css('a').first.attributes["href"].value }
  
  post_links.each do |post_link|
    puts "Processing #{post_link.to_s}...\n"
    dir = post_link.to_s.split('www.humblerecipes.com/')[1].gsub('/', '__').gsub('.html', '')
    next if Dir.exist?(dir)

    post_page = Nokogiri::HTML(URI.open(post_link))
    entry_body = post_page.css('div.entry-body')
    entry_more = post_page.css('div.entry-more')

    file_name = post_link.to_s.split('/').last

    Dir.mkdir(dir)

    File.open("#{dir}/#{file_name}", 'wb') { |f| f.write(entry_body.inner_html + entry_more.inner_html) }

    image_tags = entry_body.css('img')
    image_tags.each_with_index do |image_tag, index|
      image_url = image_tag.attributes["src"].value
      image_name = file_name.gsub(".html", "_#{index}")

      begin
        URI.open(image_url) do |u|
          File.open("#{dir}/#{image_name}.#{u.content_type.split('/')[1]}", 'wb') { |f| f.write(u.read) }
        end
      rescue StandardError => e
        puts "Could not get image for #{post_link.to_s}, Error: #{e.message}"
      end
    end
  end
end
