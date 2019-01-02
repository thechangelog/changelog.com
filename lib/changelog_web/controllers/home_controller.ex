defmodule ChangelogWeb.HomeController do
  use ChangelogWeb, :controller

  alias Changelog.{Person, Slack}
  alias Craisin.Subscriber

  plug RequireUser, "except from email links" when action not in [:opt_out]
  plug :scrub_params, "person" when action in [:update]

  def show(conn, %{"subscribed" => newsletter_id}), do: render(conn, :show, subscribed: newsletter_id, unsubscribed: nil)
  def show(conn, %{"unsubscribed" => newsletter_id}), do: render(conn, :show, subscribed: nil, unsubscribed: newsletter_id)
  def show(conn, _params), do: render(conn, :show, subscribed: nil, unsubscribed: nil)

  def account(conn = %{assigns: %{current_user: me}}, _params) do
    render(conn, :account, changeset: Person.update_changeset(me))
  end

  def profile(conn = %{assigns: %{current_user: me}}, _params) do
    render(conn, :profile, changeset: Person.update_changeset(me))
  end

  def update(conn = %{assigns: %{current_user: me}}, %{"person" => person_params, "from" => from}) do
    changeset = Person.update_changeset(me, person_params)

    case Repo.update(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:success, "Your #{from} has been updated! ✨")
        |> redirect(to: home_path(conn, :show))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "The was a problem updating your #{from}. 😢")
        |> render(String.to_existing_atom(from), person: me, changeset: changeset)
    end
  end

  def subscribe(conn = %{assigns: %{current_user: me}}, %{"id" => newsletter_id}) do
    Subscriber.subscribe(newsletter_id, Person.sans_fake_data(me))

    conn
    |> put_flash(:success, "You're subscribed! You'll get the next issue in your inbox 📥")
    |> redirect(to: home_path(conn, :show, subscribed: newsletter_id))
  end

  def unsubscribe(conn = %{assigns: %{current_user: me}}, %{"id" => newsletter_id}) do
    Subscriber.unsubscribe(newsletter_id, me.email)

    conn
    |> put_flash(:success, "You're no longer subscribed. Resubscribe any time 🤗")
    |> redirect(to: home_path(conn, :show, unsubscribed: newsletter_id))
  end

  def slack(conn = %{assigns: %{current_user: me}}, _params) do
    {updated_user, flash} = case Slack.Client.invite(me.email) do
      %{"ok" => true} ->
        {set_slack_id(me), "Invite sent! Check your email 🎯"}
      %{"ok" => false, "error" => "already_in_team"} ->
        {set_slack_id(me), "You're on the team! We'll see you in there ✊"}
      %{"ok" => false, "error" => error} ->
        {me, "Hmm, Slack is saying '#{error}' 🤔"}
    end

    conn
    |> assign(:current_user, updated_user)
    |> put_flash(:success, flash)
    |> redirect(to: home_path(conn, :show))
  end

  def opt_out(conn, %{"token" => token, "notification" => notification}) do
    if person = Person.get_by_encoded_id(token) do
      person
      |> Person.update_changeset(%{settings: %{notification => false}})
      |> Repo.update()
    end

    render(conn, :opt_out)
  end

  defp set_slack_id(person) do
    if person.slack_id do
      person
    else
      {:ok, person} = Repo.update(Person.slack_changes(person, "pending"))
      person
    end
  end
end
