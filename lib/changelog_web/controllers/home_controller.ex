defmodule ChangelogWeb.HomeController do
  use ChangelogWeb, :controller

  alias Changelog.{Person, Slack}
  alias Craisin.Subscriber

  plug RequireUser

  def show(conn, _params) do
    render(conn, :show)
  end

  def edit(conn = %{assigns: %{current_user: me}}, _params) do
    render(conn, :edit, changeset: Person.changeset(me))
  end

  def subscriptions(conn, _params) do
    render(conn, :subscriptions)
  end

  def profile(conn = %{assigns: %{current_user: me}}, _params) do
    render(conn, :profile, changeset: Person.changeset(me))
  end

  def update(conn = %{assigns: %{current_user: me}}, %{"person" => person_params}) do
    changeset = Person.changeset(me, person_params)

    case Repo.update(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:success, "Your profile has been updated! ✨")
        |> redirect(to: home_path(conn, :show))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "The was a problem updating your profile 😢")
        |> render(:edit, person: me, changeset: changeset)
    end
  end

  def subscribe(conn = %{assigns: %{current_user: me}}, %{"id" => newsletter_id}) do
    Subscriber.subscribe(newsletter_id, me)

    conn
    |> put_flash(:success, "One more step! Check your email to confirm your subscription. Then we'll hook you up 📥")
    |> render(:show)
  end

  def unsubscribe(conn = %{assigns: %{current_user: me}}, %{"id" => newsletter_id}) do
    Subscriber.unsubscribe(newsletter_id, me.email)

    conn
    |> put_flash(:success, "You're no longer subscribed. Come back any time 🤗")
    |> render(:show)
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
    |> render(:show)
  end

  defp set_slack_id(person) do
    if person.slack_id do
      person
    else
      {:ok, person} = Repo.update(Person.slack_changeset(person, "pending"))
      person
    end
  end
end
