defmodule ChangelogWeb.Admin.EpisodeView do
  use ChangelogWeb, :admin_view

  alias Changelog.{Episode, Person, Podcast, Sponsor, StringKit, Topic}
  alias ChangelogWeb.{EpisodeView, PersonView, TimeView}
  alias ChangelogWeb.Admin.{EpisodeRequestView, PodcastView, SharedView}

  def audio_filename(episode), do: EpisodeView.audio_filename(episode)
  def plusplus_filename(episode), do: EpisodeView.plusplus_filename(episode)
  def audio_url(episode), do: EpisodeView.audio_url(episode)
  def plusplus_url(episode), do: EpisodeView.plusplus_url(episode)
  def embed_code(episode), do: EpisodeView.embed_code(episode)
  def embed_iframe(episode, theme), do: EpisodeView.embed_iframe(episode, theme)
  def megabytes(episode), do: EpisodeView.megabytes(episode)
  def megabytes(episode, type), do: EpisodeView.megabytes(episode, type)
  def numbered_title(episode), do: EpisodeView.numbered_title(episode)

  def agents(episode_stats) when is_list(episode_stats) do
    episode_stats
    |> Enum.map(&(&1.demographics["agents"]))
    # remove (raw) duplicates, adding up download counts along the way
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(acc, map, fn _k, v1, v2 -> v1 + v2 end)
    end)
    # identify agents from raw user agents
    |> Enum.map(fn {ua, count} ->
      %{name: name, type: type} = Changelog.AgentKit.identify(ua)
      %{name => %{"type" => type, "count" => count, "raw" => [ua]}}
    end)
    # remove (id'd) duplicates, adding download counts and accumulating raw user agents
    |> Enum.reduce(%{}, fn map, acc ->
      Map.merge(acc, map, fn _k, v1, v2 ->
        %{"type" => v1["type"], "count" => v1["count"] + v2["count"], "raw" => v1["raw"] ++ v2["raw"]}
        end)
    end)
    |> Enum.filter(fn {_name, data} -> data["type"] != "bot" end)
  end

  def sum_downloads(agents) do
    Enum.reduce(agents, 0, fn {_name, data}, acc -> acc + data["count"] end)
  end

  def last_stat_date(podcast) do
    case PodcastView.last_stat(podcast) do
      stat = %{} ->
        {:ok, result} = Timex.format(stat.date, "{Mshort} {D}")
        result

      nil ->
        "never"
    end
  end

  def line_chart_data(stats) when is_list(stats) do
    stats = Enum.reverse(stats)

    data =
      case length(stats) do
        l when l <= 45 -> get_chart_data(stats)
        l when l <= 365 -> get_chart_data_grouped_by(:week, stats)
        l when l <= 730 -> get_chart_data_grouped_by(:month, stats)
        _else -> get_chart_data_grouped_by(:year, stats)
      end

    Jason.encode!(data)
  end

  defp get_chart_data_grouped_by(interval, stats) do
    {title, grouper} =
      case interval do
        :week -> {"Week Chart", &Timex.beginning_of_week/1}
        :month -> {"Month Chart", &Timex.beginning_of_month/1}
        :year -> {"Year Chart", &Timex.beginning_of_year/1}
      end

    stats
    |> Enum.map(fn stat -> Map.put(stat, :date, grouper.(stat.date)) end)
    |> Enum.group_by(& &1.date)
    |> Enum.map(fn {date, list} ->
      %{
        date: date,
        downloads: list |> Enum.map(& &1.downloads) |> Enum.sum()
      }
    end)
    |> Enum.sort(&Timex.before?(&1.date, &2.date))
    |> get_chart_data(title)
  end

  defp get_chart_data(stats, title \\ "Day Chart") do
    %{
      title: title,
      categories: Enum.map(stats, &stat_chart_date/1),
      series: [
        %{name: "Downloads", data: Enum.map(stats, &Float.round(&1.downloads))}
      ]
    }
  end

  defp stat_chart_date(stat) do
    {:ok, date} = Timex.format(stat.date, "{M}/{D}/{YYYY}")
    date
  end

  def downloads_link(label, assigns = %{downloads: downloads, conn: conn, current_user: user}) do
    count = SharedHelpers.pretty_downloads(downloads[label])
    podcast = Map.get(assigns, :podcast)

    if Policies.Admin.Page.downloads(user) do
      if podcast do
        link(count,
          to: Routes.admin_page_path(conn, :downloads, range: label, podcast: podcast.slug)
        )
      else
        link(count, to: Routes.admin_page_path(conn, :downloads, range: label))
      end
    else
      count
    end
  end

  def render("performance.json", %{stats: stats}) do
    %{
      title: "Episode Performance",
      series: [
        %{
          name: "Launch",
          data:
            Enum.map(stats, fn {slug, downloads, title, _total} ->
              %{x: slug, y: downloads, title: title}
            end)
        },
        %{
          name: "Total",
          data:
            Enum.map(stats, fn {slug, _downloads, title, total} ->
              %{x: slug, y: total, title: title}
            end)
        }
      ]
    }
  end

  def request_options(requests) do
    Enum.map(requests, fn request ->
      {EpisodeRequestView.description(request), request.id}
    end)
  end

  def status_label(episode) do
    if episode.published do
      content_tag(:span, "Published", class: "ui tiny green basic label")
    else
      content_tag(:span, "Draft", class: "ui tiny yellow basic label")
    end
  end

  def show_or_preview_path(podcast, episode) do
    if Episode.is_public(episode) do
      ~p"/#{podcast.slug}/#{episode.slug}"
    else
      ~p"/#{podcast.slug}/#{episode.slug}/preview"
    end
  end

  def stat_date(nil), do: "never"

  def stat_date(stat) do
    {:ok, result} = Timex.format(stat.date, "{WDshort}, {M}/{D}")
    result
  end

  def type_options do
    Episode.Type.__enum_map__()
    |> Enum.map(fn {k, _v} -> {String.capitalize(Atom.to_string(k)), k} end)
  end
end
