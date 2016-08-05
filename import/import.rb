require "rubygems"
require "bundler/setup"
require "nokogiri"
require "pg"
require "sequel"
require "pry"

class Nokogiri::XML::Element
  def child_named name
    self.children.find { |c| c.name == name }
  end
end

class DataWrapper
  attr_reader :el
  def initialize(el); @el = el; end
  def published_at; DateTime.parse(el.child_named("pubDate").text); end
end

class Author < DataWrapper
  def email; el.child_named("author_email").text; end
  def handle; el.child_named("author_login").text; end
  def id; el.child_named("author_id").text.to_i; end
  def name; el.child_named("author_display_name").text; end
end

class Episode < DataWrapper
  def guid; el.child_named("guid").text; end
  def slug; el.child_named("link").text.split("/").last; end
  def summary; el.xpath("content:encoded").text; end
  def title; el.child_named("title").text.gsub(/\A\d+:\s/, ""); end
  def tags; el.xpath("category[@domain='post_tag']").map(&:text); end
end

class Post < DataWrapper
  def author_handle; el.xpath("dc:creator").text; end
  def body; el.xpath("content:encoded").text; end
  def categories; el.xpath("category[@domain='category']").map(&:text); end
  def go_time?; categories.include?("Go Time"); end
  def podcast?; categories.include?("Podcast"); end
  def published?; el.xpath("wp:status").text == "publish"; end
  def slug; el.child_named("post_name").text; end
  def title; el.child_named("title").text; end
  def tags; el.xpath("category[@domain='post_tag']").map(&:text); end
end

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
    @authors ||= doc.xpath("//channel/wp:author").map { |el| Author.new el }
  end

  def posts
    @posts ||= doc.xpath("//channel/item").map { |el| Post.new el }.select(&:published?).reject(&:podcast?).reject(&:go_time?)
  end

  def episodes
    @episodes ||= doc.xpath("//channel/item").reverse.map { |el| Episode.new el }
  end

  def import_episodes
    begin
      podcast_id = db[:podcasts].where(slug: ENV["PODCAST_SLUG"]).first[:id]
    rescue
      abort "Must specify valid PODCAST_SLUG env var"
    end

    episodes.each do |episode|
      handling_data_issues do
        episode_id = db[:episodes].insert({
          podcast_id: podcast_id,
          title: episode.title,
          slug: episode.slug,
          published: true,
          published_at: episode.published_at,
          recorded_at: episode.published_at,
          summary: episode.summary
        }.merge(timestamps))

        episode.tags.each do |tag|
          if channel = db[:channels].where(name: tag).first
            db[:episode_channels].insert({
              channel_id: channel[:id],
              episode_id: episode_id
            }.merge(timestamps))
          end
        end
      end
    end
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

  def import_posts
    posts.each do |post|
      handling_data_issues do
        author_id = db[:people].where(handle: post.author_handle).first[:id]
        post_id = db[:posts].insert({
          title: post.title,
          slug: post.slug,
          published: true,
          published_at: post.published_at,
          body: post.body,
          author_id: author_id
        }.merge(timestamps))

        post.tags.each do |tag|
          if channel = db[:channels].where(name: tag).first
            db[:post_channels].insert({
              channel_id: channel[:id],
              post_id: post_id
            }.merge(timestamps))
          end
        end
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
binding.pry
# importer.import_people
# importer.import_posts
# importer.import_episodes
