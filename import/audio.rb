require "rubygems"
require "bundler/setup"
require "mechanize"
require "pry"

audio_dir = File.expand_path(ENV["IMPORT_DIR"] || "")
mp3s = Dir["#{audio_dir}/*.mp3"]

if mp3s.empty?
  abort "No mp3s found in #{audio_dir}. Must specify valid IMPORT_DIR that contains mp3s."
end

root = "https://2016.changelog.com"
cookies = "cookies.yml"
mech = Mechanize.new

if File.exist? cookies
  mech.cookie_jar.load cookies
  puts "Loading auth from cookies..."
else
  puts "Getting auth..."
  abort "Must set valid AUTH_TOKEN env var" unless token = ENV["AUTH_TOKEN"]
  mech.get("#{root}/in/#{token}")
  mech.cookie_jar.save_as cookies
end

mp3s.each do |mp3|
  podcast, slug = mp3.gsub(".mp3", "").split("-")
  episode_page = mech.get("#{root}/admin/podcasts/#{podcast}/episodes/#{slig}/edit")

  if episode_page.search(".js-audio-file").any?
    puts "skipping #{mp3}. Audio file exists..."
  else
    puts "Uploading #{mp3}..."
    start_time = Time.now
    episode_form = episode_page.forms.first
    upload_field = episode_form.file_uploads.first
    upload_field.file_name = mp3
    episode_form.submit
    total_time = (Time.now - start_time).round
    puts "Finished uploading in #{total_time / 60} minutes, #{total_time % 60} seconds."
  end
end

