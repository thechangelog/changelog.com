defmodule Mix.Tasks.Changelog.Uploads.Process do
	use Mix.Task

	alias Changelog.{Files, Person, NewsSource, Repo, Sponsor, Topic}

	@shortdoc "Processes uploaded files given current transform rules"

	def run(_) do
		Mix.Task.run("app.start")

		process_news_sources()
		process_people()
		process_sponsors()
		process_topics()
	end

	def process_news_sources do
		sources =
			NewsSource
			|> NewsSource.with_icon()
			|> NewsSource.newest_last()
			|> Repo.all()

		IO.puts "Processing icons for #{length(sources)} news sources."

		for source <- sources do
			url = Files.Icon.url({source.icon, source})
			IO.puts "Processing icon for news source #{url}"
			Files.Icon.store({url, source})
		end
	end

	def process_people do
		people =
			Person
			|> Person.with_avatar()
			|> Person.newest_last()
			|> Repo.all()

		IO.puts "Processing avatars for #{length(people)} people."

		for person <- people do
			url = Files.Avatar.url({person.avatar, person})
			IO.puts "Processing avatar for person #{url}"
			Files.Avatar.store({url, person})
		end
	end

	def process_sponsors do
		sponsors =
			Sponsor
			|> Sponsor.newest_last()
			|> Repo.all()

		IO.puts "Processing uploads for #{length(sponsors)} sponsors."

		for sponsor <- sponsors do
			if sponsor.avatar do
				url = Files.Avatar.url({sponsor.avatar, sponsor})
				IO.puts "Processing avatar for sponsor #{url}"
				Files.Avatar.store({url, sponsor})
			end

			if sponsor.color_logo do
				url = Files.ColorLogo.url({sponsor.color_logo, sponsor})
				IO.puts "Processing color logo for sponsor #{url}"
				Files.ColorLogo.store({url, sponsor})
			end

			if sponsor.dark_logo do
				url = Files.DarkLogo.url({sponsor.dark_logo, sponsor})
				IO.puts "Processing dark logo for sponsor #{url}"
				Files.DarkLogo.store({url, sponsor})
			end

			if sponsor.light_logo do
				url = Files.LightLogo.url({sponsor.light_logo, sponsor})
				IO.puts "Processing light logo for sponsor #{url}"
				Files.LightLogo.store({url, sponsor})
			end
		end
	end

	def process_topics do
		topics =
			Topic
			|> Topic.with_icon()
			|> Topic.newest_last()
			|> Repo.all()

		IO.puts "Processing icons for #{length(topics)} topics."

		for topic <- topics do
			url = Files.Icon.url({topic.icon, topic})
			IO.puts "Processing icon for topic ##{url}"
			Files.Icon.store({url, topic})
		end
	end
end
