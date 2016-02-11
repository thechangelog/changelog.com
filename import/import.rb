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
class Author < Struct.new(:id, :name, :email, :handle); end

class Importer
  def db
    @db ||= Sequel.postgres("changelog_dev", host: "localhost")
  end

  def doc
    @doc ||= File.open(File.expand_path(ENV["IMPORT_FILE"])) { |f| Nokogiri::XML(f) }
  rescue
    abort "Must specify valid IMPORT_FILE env var"
  end

  def authors
    @authors ||= doc.xpath("//channel/wp:author").map { |el|
      Author.new(
        el.child_with_name("author_id").text.to_i,
        el.child_with_name("author_display_name").text,
        el.child_with_name("author_email").text,
        el.child_with_name("author_login").text
      )
    }
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

  def import_people
    authors.each do |author|
      handling_data_issues do
        db[:people].insert({
          name: author.name,
          email: author.email,
          handle: author.handle
        }.merge(timestamps))
      end
    end
  end

  def import_topics
    tags.each do |tag|
      handling_data_issues do
        db[:topics].insert({
          name: tag.name,
          slug: tag.slug
        }.merge(timestamps))
      end
    end
  end

  private

  def timestamps
    {
      inserted_at: Time.now,
      updated_at: Time.now
    }
  end

  def handling_data_issues
    yield
  rescue Sequel::UniqueConstraintViolation
    # next plz
  end
end

importer = Importer.new

importer.import_topics
importer.import_people
