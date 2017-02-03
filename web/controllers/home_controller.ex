defmodule Changelog.HomeController do
  use Changelog.Web, :controller

  alias Changelog.{Person, Slack}
  alias Craisin.Subscriber

  plug RequireUser

  def show(conn, _params) do
    render(conn, :show)
  end

  def edit(%{assigns: %{current_user: current_user}} = conn, _params) do
    render(conn, :edit, changeset: Person.changeset(current_user))
  end

  def update(%{assigns: %{current_user: current_user}} = conn, %{"person" => person_params}) do
    changeset = Person.changeset(current_user, person_params)

    case Repo.update(changeset) do
      {:ok, _person} ->
        conn
        |> put_flash(:success, "Your profile has been updated! ✨")
        |> redirect(to: home_path(conn, :show))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "The was a problem updating your profile 😢")
        |> render(:edit, person: current_user, changeset: changeset)
    end
  end

  def subscribe(%{assigns: %{current_user: current_user}} = conn, %{"id" => newsletter_id}) do
    Subscriber.subscribe(newsletter_id, current_user.email, current_user.name)

    conn
    |> put_flash(:success, "One more step! Check your email to confirm your subscription. Then we'll hook you up 📥")
    |> render(:show)
  end

  def unsubscribe(%{assigns: %{current_user: current_user}} = conn, %{"id" => newsletter_id}) do
    Subscriber.unsubscribe(newsletter_id, current_user.email)

    conn
    |> put_flash(:success, "You're no longer subscribed. Come back any time 🤗")
    |> render(:show)
  end

  def slack(%{assigns: %{current_user: current_user}} = conn, _params) do
    {updated_user, flash} = case Slack.Client.invite(current_user.email) do
      %{"ok" => true} ->
        {set_slack_id(current_user), "Invite sent! Check your email 🎯"}
      %{"ok" => false, "error" => "already_in_team"} ->
        {set_slack_id(current_user), "You're on the team! We'll see you in there ✊"}
      %{"ok" => false, "error" => error} ->
        {current_user, "Hmm, Slack is saying '#{error}' 🤔"}
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
