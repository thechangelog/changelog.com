require "rubygems"
require "bundler/setup"
require "nokogiri"
require "pg"
require "sequel"
require "pry"

class Nokogiri::XML::Element
  def child_with_name name
    self.children.find { |c| c.name == name }
  end
end

class Tag < Struct.new(:id, :name, :slug); end

class Importer
  def db
    @db ||= Sequel.postgres("changelog_dev", host: "localhost")
  end

  def doc
    @doc ||= File.open(File.expand_path(ENV["IMPORT_FILE"])) { |f| Nokogiri::XML(f) }
  rescue
    abort "Must specify valid IMPORT_FILE env var"
  end

  def tags
    @tags ||= doc.xpath("//channel/wp:tag").map { |el|
      Tag.new(
        el.child_with_name("term_id").text.to_i,
        el.child_with_name("tag_name").text,
        el.child_with_name("tag_slug").text
      )
    }
  end

  def import_topics
    tags.each do |tag|
      begin
        db[:topics].insert({
          name: tag.name,
          slug: tag.slug,
          inserted_at: Time.now,
          updated_at: Time.now
        })
      rescue Sequel::UniqueConstraintViolation
        # next plz
      end
    end
  end
end

importer = Importer.new

#import.import_topics
#import.import_people
