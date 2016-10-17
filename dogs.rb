# enconding: utf-8

require 'open-uri'
require 'nokogiri'
require 'fileutils'

BASE_URL    = "http://www.abra.org.pt"
DOGS_URL    = "/caes.html"
DOGS_FOLDER = Dir.pwd + "/data/dogs"

# Create folder to store dogs data if it doesn't exist already.
FileUtils.mkdir_p(DOGS_FOLDER) unless File.directory?(DOGS_FOLDER)

# Request the initial html page.
page    = Nokogiri::HTML(open(BASE_URL + DOGS_URL))
links   = page.css("div.subCategoryContainer div.subCategory h2 a")
threads = []

for i in 0...links.size do
  threads << Thread.new {
    # Open each link and process dog names.
    page_url  = BASE_URL + links[i]['href'].gsub('ã','a')
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
      dogs      = list_page.css("div.catItemView")

      dogs.each { |dog|
        dog.css("div.catItemHeader h3.catItemTitle a").each { |dog_url|
          dog_name  = dog_url.content().strip()
          dog_id    = dog_url['href'].scan(/\d+/).last
          dog_image = dog.css("div.catItemBody div.catItemImageBlock span.catItemImage a img")

          open(BASE_URL + dog_image.first['src']) { |image|
            File.open(DOGS_FOLDER + "/[#{dog_id}] #{dog_name}.jpg", "wb") do |file|
              file.puts image.read
            end
          } if !dog_image.empty?
        }
      }

      current_page  += 1
      current_url   = page_url + "?start=#{current_page * 25}"
    end
  }
end

threads.each { |thread| thread.join }
