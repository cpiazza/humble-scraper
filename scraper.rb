require "HTTParty"
require 'open-uri'
require 'nokogiri'
require 'pry'

## Get all the archive links
archive_html = open("https://www.humblerecipes.com/archives.html")
archive_page = Nokogiri::HTML(archive_html)
archive_links = archive_page.css('li.archive-list-item').map { |e| e.children.first.attributes["href"].value }

## Follow each archive link
archive_links.each do |archive_link|
  month_html = open(archive_link)
  month_page = Nokogiri::HTML(month_html)

  ## Collect the links to each individual post
  post_links = month_page.css('p.entry-more-link').map { |e| e.children.css('a').first.attributes["href"].value }
  post_links.each { |l| puts l }
end
