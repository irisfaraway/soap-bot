require 'nokogiri'
require 'open-uri'
require 'uri'

# Set up arrays for summaries and guide pages
@guide_pages = []
@all_summaries = []

# Set up the list of all guide pages to scrape
def make_guide_page_list
  puts 'Making a list of all the pages to scrape...'
  i = 0
  # Add all the pages we want to scrape to the guide array
  77.times do
    i += 1
    page = "http://www.bbc.co.uk/programmes/b006m86d/episodes/guide?page=#{i}"
    @guide_pages << page
  end
end

# Scrape the pages for plot summaries
def scrape(page)
  summaries = []

  # Get all the content
  html = open(page)
  doc = Nokogiri::HTML(html)

  # Get each episode summary
  doc.css('.programme__synopsis span').each do |summary|
    # Add the summary text to the main array
    @all_summaries << summary.text
  end
end

make_guide_page_list

@guide_pages.each do |page|
  puts "Scraping #{page}"
  scrape(page)
end

# Write summaries to txt file
File.open('corpus/eastenders.txt', 'w+') do |file|
  puts 'Writing to file...'
  @all_summaries.each do |summary|
    file.write(summary)
    file.write("\n")
  end
end

puts 'Done!'
