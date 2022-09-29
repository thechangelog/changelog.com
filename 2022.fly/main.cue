// vim: tabstop=4
package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

// TODO:
// - [ ] create Wireguard peer connection
//       - run a fly command
//       - write a file, i.e. changelog.conf (Wireguard config)
//       - run `open -a Wireguard changelog.conf on the client`
//
// - [ ] do not fail if PostgreSQL instance created
//       - put it in a script (workaround)
//
// - [ ] import PostgreSQL from last backup
//   fly scale count 0
//   fly postgres connect postgres-2022-03-12
//   drop database changelog with (force);
//   create database changelog;
//   ^d
//   psql --host=postgres-2022-03-12.internal --username=postgres --dbname=changelog < ~/Downloads/prod-<TAB>
//   fly scale count 1
//
// - [ ] connect to PostgreSQL changelog instance
//
// - [ ] import secrets
//   make secrets
//
// - [ ] write a file on the client - .envrc - by joining multiple stdout
//
// - [ ] deploy app

dagger.#Plan & {
	client: {
		filesystem: {
			"./": read: {
				contents: dagger.#FS
				exclude: ["bin"]
			}
			"./.envrc": write: {
				contents: actions.actions.envrc.output
			}
		}
		// TODO: how do we append this stdout to ./.envrc?
		commands: {
			secrets: {
				name: "make"
				args: [
					"--directory", "../2021",
					"--no-print-directory",
					"env-secrets",
				]
			}
		}
		env: {
			FLY_ACCESS_TOKEN:                dagger.#Secret
			CM_SMTP_TOKEN:                   dagger.#Secret
			CM_API_TOKEN:                    dagger.#Secret
			GITHUB_CLIENT_ID:                dagger.#Secret
			GITHUB_CLIENT_SECRET:            dagger.#Secret
			GITHUB_API_TOKEN:                dagger.#Secret
			TURNSTILE_SECRET_KEY:            dagger.#Secret
			RECAPTCHA_SECRET_KEY:            dagger.#Secret
			HN_USER:                         dagger.#Secret
			HN_PASS:                         dagger.#Secret
			AWS_ACCESS_KEY_ID:               dagger.#Secret
			AWS_SECRET_ACCESS_KEY:           dagger.#Secret
			BACKUPS_AWS_ACCESS_KEY:          dagger.#Secret
			BACKUPS_AWS_SECRET_KEY:          dagger.#Secret
			SHOPIFY_API_KEY:                 dagger.#Secret
			SHOPIFY_API_PASSWORD:            dagger.#Secret
			TWITTER_CONSUMER_KEY:            dagger.#Secret
			TWITTER_CONSUMER_SECRET:         dagger.#Secret
			SECRET_KEY_BASE:                 dagger.#Secret
			SIGNING_SALT:                    dagger.#Secret
			SLACK_INVITE_API_TOKEN:          dagger.#Secret
			SLACK_APP_API_TOKEN:             dagger.#Secret
			BUFFER_TOKEN:                    dagger.#Secret
			COVERALLS_REPO_TOKEN:            dagger.#Secret
			ALGOLIA_APPLICATION_ID:          dagger.#Secret
			ALGOLIA_API_KEY:                 dagger.#Secret
			PLUSPLUS_SLUG_1:                 dagger.#Secret
			FASTLY_API_TOKEN:                dagger.#Secret
			GRAFANA_API_KEY:                 dagger.#Secret
			PROMETHEUS_BEARER_TOKEN_PROM_EX: dagger.#Secret
			SENTRY_AUTH_TOKEN:               dagger.#Secret
		}
	}
	actions: {
		config: {
			// TODO: find latest version → https://github.com/superfly/flyctl/releases
			fly: version: "0.0.306"
			org:    "changelog"
			region: "iad"
			app: name: "changelog-2022-03-13"
			postgres: {
				name: "postgres-2022-03-12"
				instance: {
					count: "2"
					type:  "dedicated-cpu-2x"
				}
				volume: size: "10"
			}
		}
		_fly: docker.#Run & {
			// Default user (curl_user)
			// does not have sufficient privileges
			// to write to this location
			user:    "root"
			workdir: "/usr/local/bin"
			command: {
				name: string | *"flyctl"
			}
			// https://fly.io/docs/reference/runtime-environment/
			env: {
				FLY_ACCESS_TOKEN: client.env.FLY_ACCESS_TOKEN
				FLY_VERSION:      config.fly.version
			}
		}
		_fly_cli: docker.#Build & {
			steps: [
				docker.#Pull & {
					source: "curlimages/curl"
				},
				_fly & {
					command: {
						name: "curl"
						args: [
							"--location",
							"--output", "fly.install.sh",
							"--verbose",
							"https://fly.io/install.sh",
						]
					}
				},
				_fly & {
					env: FLYCTL_INSTALL: "/usr/local"
					command: {
						name: "sh"
						args: ["fly.install.sh"]
					}
				},
				_fly & {
					command: args: ["help"]
				},
			]
		}
		// List all available fly.io regions: https://fly.io/docs/reference/regions/
		regions: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: ["platform", "regions"]
		}
		// List all available fly.io VM types: https://fly.io/docs/about/pricing/#virtual-machines
		vms: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: ["platform", "vm-sizes"]
		}
		// Create PostgreSQL instance
		postgres: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"postgres", "create",
				"--organization", config.org,
				"--region", config.region,
				"--name", config.postgres.name,
				"--initial-cluster-size", config.postgres.instance.count,
				"--vm-size", config.postgres.instance.type,
				"--volume-size", config.postgres.volume.size,
				// "--help",
			]
		}
		// Tail PostgreSQL changelog instance logs
		postgres_logs: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"logs",
				"--app", config.postgres.name,
			]
		}

		// Tail app logs
		app_logs: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"logs",
				"--app", config.app.name,
			]
		}

		// Show app info
		app_info: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"info",
				"--app", config.app.name,
			]
		}

		// Show app status
		app_status: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"status",
				"--app", config.app.name,
			]
		}
		// TODO: combine with app info

		// Show app status
		app_releases: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"apps", "releases",
				"--app", config.app.name,
			]
		}
		// TODO: combine with app info

		// Show app scale
		app_scale: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"scale", "show",
				"--app", config.app.name,
			]
		}
		// TODO: combine with app info

		// Show app health checks
		app_checks: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"checks", "list",
				"--app", config.app.name,
			]
		}
		// TODO: combine with app info

		// Show app history
		app_history: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"history",
				"--app", config.app.name,
			]
		}

		// Stop app
		app_stop: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"scale", "count", "0",
				"--app", config.app.name,
			]
		}

		// Start app
		app_start: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"scale", "count", "1",
				"--app", config.app.name,
			]
		}

		// List all apps
		apps: _fly & {
			input:  _fly_cli.output
			always: true
			command: args: [
				"apps", "list",
			]
		}

	}
}
