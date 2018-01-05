require "rubygems"
require "bundler/setup"
require "mechanize"
require "pry"

topics_dir = File.expand_path(ENV["IMPORT_DIR"] || "")
topic_dirs = Dir["#{topics_dir}/topics/*"].map { |string| Pathname.new string }

root = "https://changelog.com"
cookies = "cookies.yml"
mech = Mechanize.new

if File.exist? cookies
  mech.cookie_jar.load cookies
  puts "Loading auth from cookies..."
else
  puts "Getting auth..."
  abort "Must set valid AUTH_TOKEN env var" unless token = ENV["AUTH_TOKEN"]
  mech.get "#{root}/in/#{token}"
  mech.cookie_jar.save_as cookies
end

topic_dirs.each do |topic_dir|
  slug = topic_dir.basename.to_s
  icon = topic_dir.join("#{slug}.png").to_s
  data = YAML.load_file topic_dir.join "index.md"
  name = data["display_name"]
  description = data["short_description"]

  begin
    topic_page = mech.get "#{root}/admin/topics/#{slug}/edit"
    puts "editing #{slug}..."
  rescue Mechanize::ResponseCodeError
    topic_page = mech.get "#{root}/admin/topics/new"
    puts "new topic #{slug}..."
  end

  topic_form = topic_page.forms.first
  topic_form["topic[slug]"] = slug
  topic_form["topic[name]"] = name
  topic_form["topic[description]"] = description

  if File.exist? icon
    icon_field = topic_form.file_uploads.first
    icon_field.file_name = icon
  end

  topic_form.submit
end
