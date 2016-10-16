# enconding: utf-8

require 'open-uri'
require 'nokogiri'

BASE_URL  = "http://www.abra.org.pt"
DOGS_URL  = "/caes.html"

page  = Nokogiri::HTML(open(BASE_URL + DOGS_URL))
links = page.css("div.subCategoryContainer div.subCategory h2 a")

links.each do |link|
  # Open each link and process dog names.
  page_url  = BASE_URL + link['href'].gsub('ã','a')
  list_page = Nokogiri::HTML(open(page_url))

  # Get number of pages from the pagination links.
  pagination_links  = list_page.css("div.pagination a")
  last_page         = pagination_links[-1]['href'].scan(/\d+/).last.to_i / 25
  current_page      = 0
  current_url       = page_url + "?start=0"

  while current_page <= last_page do
    puts "===================================>"
    puts("Processing #{current_url}...")
    puts "===================================>"
    list_page = Nokogiri::HTML(open(current_url))
    dog_names = list_page.css("div.catItemHeader h3.catItemTitle a")

    dog_names.each { |name| puts("\t#{name.content.strip()} \t\t\t[#{name['href'].scan(/\d+/).last.to_i }]") }
    current_page  += 1
    current_url   = page_url + "?start=#{current_page * 25}"
  end
end
