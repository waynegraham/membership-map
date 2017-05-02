require 'geocoder'
require 'colorize'
require 'dotenv'
require 'mechanize'

require 'csv'
require 'date'
require 'erb'
require 'json'

Dotenv.load

task default: 'process:all'

DLF_MEMBERS = "https://www.diglib.org/members/"
puts "Getting the data from #{DLF_MEMBERS}"
@a = Mechanize.new
@page = @a.get(DLF_MEMBERS)
@dlf_members = "Membership.csv"
@features = []
@failures = []
@no_links = []

def split_address(institution, address)
  unless address.nil?
    parts = address.split('<BR/>')
    puts parts.last.red
    return "#{institution}, #{parts.last}"
  else
    return "#{institution} #{address}"
  end
end

namespace :process do
  desc 'Process members in the MemberSuite output'
  task :all => [:map]

  desc "Import members for geocoding"
  task :map do
    CSV.foreach(@dlf_members) do |row|
      puts "Geocoding #{row[1]}...".green

      lookup = split_address(row[1], row[6])
      # address = "#{row[1]} #{row[8]} #{row[10]}"

      result = Geocoder.search(lookup)
      link = @page.link_with(text: /^(#{row[1]})+/)
      uri = "#"
      uri = link.resolved_uri unless link.nil?

      feature = {
        institution: row[1],
        start_date:  row[4],
        address:     lookup,
        web_path:    uri,
      }

      if uri == '#'
        @no_links << feature
      end

      unless result.empty?
        geocode = {
          latitude: result.first.latitude,
          longitude: result.first.longitude,
          id: result.first.place_id
        }

        feature.merge! geocode
        @features << feature
      else
        @failures << feature
      end

      CSV.open('geocoded.csv', 'w') do |writer|
        @features.each do |f|
          writer << [f[:institution], f[:address], f[:start_date], f[:web_path], f[:latitude], f[:longitude], f[:id]]
        end
      end

      CSV.open('failures.csv', 'w') do |writer|
        @failures.each do |f|
          writer << [f[:institution], f[:address], f[:start_date], f[:web_path]]
        end
      end

    end

    puts "\nTake a look at these without URLs on #{DLF_MEMBERS}"
    @no_links.each do |institution|
      puts institution[:institution].to_s
    end

  end
end

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
