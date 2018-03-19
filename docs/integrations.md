# Integrations with external providers

This application make use of different external services (e.g. `GitHub`, `Google API`, `Slack`, and others) to work properly. In this page we try to document how to configure and use all of these external services.

## Google Calendar

The Google Calendar Service is used when we create, updated or delete an Episode. In order to use the `Google Calendar` some steps are needed:

1. Create a `Google Service Account`

  go to `console.developers.google.com` -> `Credentials` -> `Service Account Key`

2. Save the `.json` key somewhere

3. Export the environment variable `GOOGLE_APPLICATION_CREDENTIALS`

  ```
  mix clean
  export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/key.json"
  ```

4. Share a `Google Calendar` with the `Google Service Account` we created at step 1.

go to `calendar.google.com` -> `Settings` -> `Select the calendar you want to share` -> `Look for "Share with specific people"` -> Add the email (_Service account ID_) associated to the Google Service Account created at the step 1.

5. Configure the `GoogleCalendarService` in the config files (`/config/*.exs`)

configuration for the `test` environment:

config/test.exs

```
...
# Configure CalendarService
config :changelog, Changelog.CalendarService,
  adapter: Changelog.CalendarService,
  google_calendar_id: GOOGLE_CALENDAR_ID
...
```

configuration for the `development` environment:

config/dev.exs

```
...
# Configure CalendarService
config :changelog, Changelog.CalendarService,
  adapter: Changelog.Services.GoogleCalendarService,
  google_calendar_id: GOOGLE_CALENDAR_ID
...
```

To find the `google_calendar_id` of the Calendar you shared with the `Google Service Account`, just go to `calendar.google.com` -> `Settings` -> `Select the calendar you want to share` -> `Look for "Integrate calendar"` -> `Calendar ID`

6. How to run the integration tests

```
mix test --trace --only external
```

