#! /usr/bin/env ruby

require 'csv'
require 'erb'

require 'colorize'
require 'dotenv'
require 'geocoder'
require 'mechanize'

def render_erb(template_path)
  template = File.open(template_path, 'r').read
  erb = ERB.new(template)
  erb.result(binding)
end

def write_file(path, contents)
  file = File.open(path, 'w')
  file.write(contents)
rescue IOError => error
  puts 'File not writable. Check your permissions'
  puts error.inspect
ensure
  file.close unless file.nil?
end

@features = []

puts "Fetching the members page from https://www.diglib.org/members/".yellow
a = Mechanize.new
# page = a.get('https://www.diglib.org/members/')
counter = 0
CSV.foreach("Membership.csv") do |row|

  address = "#{row[0]} #{row[7]} #{row[7]} #{row[8]} #{row[9]}"

  puts address
break
  result = Geocoder.search(address)

  puts result.inspect

  # puts "Looking up location of #{row[1]}".green

  # find text on the page and grab the link
  link = page.link_with(:text => row[1])
  uri = "#"
  uri = link.resolved_uri unless link.nil?



  # @failures = []
  #
  # unless result.size == 0
  #   feature = {
  #     institution: row[1],
  #     start_date:  row[2],
  #     address:     row[5],
  #     latitude:    result.first.latitude,
  #     longitude:   result.first.longitude,
  #     web_path:    uri,
  #     id:          result.first.place_id
  #   }
  #
  #   @features << feature
  # else
  #   # puts "Could not locate #{row[1]}".red
  #   feature = {
  #     institution: row[1],
  #     address:     row[5],
  #     web_path:    uri
  #   }
  #   @failures << feature
  #   puts feature.to_s.red
  # end

end

puts "\nRendering geoJSON file".red
contents = render_erb('templates/members.js.erb')
write_file('./data/events_map.js', contents)

puts "\nRendering failure file".red
CSV.open('failures.csv', 'w') do |writer|
  @failures.each do |f|
    writer << [f[:institution], f[:address], f[:web_path]]
  end
end

puts "\nFailures to look at:"
@failures.each do |failure|
  puts failure[:institution].red
end
