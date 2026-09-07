defmodule Changelog.ReleaseTaskTest do
  use ExUnit.Case, async: false

  @root Path.expand("../..", __DIR__)

  for {mode, enabled} <- [{"1", false}, {nil, true}, {"0", true}] do
    @mode mode
    @enabled enabled

    test "application startup with release mode #{inspect(mode)}" do
      # A fresh VM avoids inspecting the Oban instance already running in ExUnit.
      code = """
      import ExUnit.Assertions
      System.put_env("APP_INSTANCE", "production")
      production = Config.Reader.read!("config/prod.exs")
      oban = production |> Keyword.fetch!(:changelog) |> Keyword.fetch!(Oban)
      assert Keyword.fetch!(oban, :queues) ==
        [default: 1, audio_updater: 2, scheduled: 2, email: 6, feeds: 5]
      oban = Keyword.merge(Application.fetch_env!(:changelog, Oban), oban)
      # Exercise the production configuration without allowing test jobs or Cron to run.
      Application.put_env(:changelog, Oban, Keyword.put(oban, :testing, :manual))
      {:ok, _} = Application.ensure_all_started(:changelog)
      children = Supervisor.which_children(Changelog.Supervisor)
      assert List.keymember?(children, Oban, 0) == #{inspect(@enabled)}
      assert is_pid(Oban.whereis(Oban)) == #{inspect(@enabled)}
      assert is_pid(Process.whereis(Changelog.Repo))
      assert is_pid(Process.whereis(ChangelogWeb.Endpoint))
      assert is_pid(Process.whereis(:app_cache))
      IO.puts("STARTUP_ISOLATION_PASS")
      """

      {output, status} =
        System.cmd(
          System.find_executable("elixir"),
          ["-S", "mix", "run", "--no-start", "--no-compile", "--no-deps-check", "-e", code],
          cd: @root,
          env: [
            {"MIX_ENV", "test"},
            {"CHANGELOG_RELEASE_TASK", @mode},
            {"ERL_FLAGS", "+S 2:2 +A 2"}
          ],
          stderr_to_stdout: true
        )

      assert status == 0, output
      assert output =~ "STARTUP_ISOLATION_PASS"
    end
  end

  describe "release hook" do
    setup do
      directory =
        Path.join(System.tmp_dir!(), "changelog-release-#{System.unique_integer([:positive])}")

      File.mkdir_p!(directory)
      on_exit(fn -> File.rm_rf!(directory) end)
      stub = Path.join(directory, "fnox")

      File.write!(stub, """
      #!/bin/sh
      printf '%s|%s\\n' "$CHANGELOG_RELEASE_TASK" "$*" >> "$CALL_LOG"
      if [ "$6" = "$FAIL_TASK" ]; then exit 17; fi
      """)

      File.chmod!(stub, 0o700)
      %{directory: directory, log: Path.join(directory, "calls")}
    end

    test "sets release mode for upload and migration in order", context do
      {_output, status} = run_hook(context, "")
      assert status == 0

      assert File.read!(context.log) ==
               "1|exec --profile production -- mix changelog.static.upload\n" <>
                 "1|exec --profile production -- mix ecto.migrate\n"
    end

    test "upload command failure prevents migration", context do
      {_output, status} = run_hook(context, "changelog.static.upload")
      assert status == 17

      assert File.read!(context.log) ==
               "1|exec --profile production -- mix changelog.static.upload\n"
    end

    test "migration command failure fails the hook", context do
      {_output, status} = run_hook(context, "ecto.migrate")
      assert status == 17
      assert length(String.split(File.read!(context.log), "\n", trim: true)) == 2
    end
  end

  defp run_hook(context, failure) do
    System.cmd("bash", [Path.join(@root, "docker/scripts/on.deploy")],
      env: [
        {"PATH", context.directory <> ":" <> System.fetch_env!("PATH")},
        {"OP_SERVICE_ACCOUNT_TOKEN", "test-only-not-a-credential"},
        {"CHANGELOG_RELEASE_TASK", "0"},
        {"CALL_LOG", context.log},
        {"FAIL_TASK", failure}
      ],
      stderr_to_stdout: true
    )
  end
end
