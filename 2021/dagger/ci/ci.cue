// STARTING POINT: https://docs.dagger.io/1012/ci
// + ../../../.circleci/config.yml
package ci

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

dagger.#Plan & {
	// Receive things from client
	input: {
		directories: {
			// App source code
			app: {}
		}
		secrets: {
			// Docker ID password
			docker: {}
		}
		params: {
			// Which Elixir base image to download
			runtime_image: docker.#Ref | *"thechangelog/runtime:2021-05-29T10.17.12Z"
			// Which test DB image to download
			test_db_image: docker.#Ref | *"circleci/postgres:12.6"
		}
	}

	// Send things to client
	output: {
	}

	// Forward network services to and from the client
	proxy: {
	}

	// Do things
	actions: {

		test: {
	
			build: #mixBuild & {
				"env": test
				app: "thechangelog"
				base: input.params.runtime_image
				source: input.directories.app.contents
			}
	
			// Run tests
			run: docker.#Run & {
				image: build.output
				script: "mix test"
				// Don't cache running tests
				// Just because we've tested a version before, doesn't mean we don't
				// want to test it again.
				always: true
			}

			db: {
				// Pull test DB image
				pull: docker.#Pull & {
					source: input.params.test_db_image
				}

				// Run test DB
				// FIXME: kill once no longer needed (when tests are done running)
				run: docker.#Run & {
					image: pull.output
				}
			}
		}
	}
}

// FIXME: move into an elixir package
// Build an Elixir application with Mix
#mixBuild: {
	// Ref to base image
	// FIXME: spin out docker.#Build for max flexibility
	//   Perhaps implement as a custom docker.#Build step?
	base: docker.#Ref

	// App name (for cache scoping)
	app: string

	// Mix environment
	env: string

	// Application source code
	source: dagger.#FS

	docker.#Build & {
                steps: [
                        // 1. Pull base image
                        docker.#Pull & {
                                source: base
                        },
                        // 2. Copy app source
                        docker.#Copy & {
                                contents: source
                                dest: "/app"
                        },
			// 3. Download dependencies into deps cache
			docker.#Run & {
				script: "mix deps.get"
				"env": MIX_ENV: env
				mounts: {
					// Same cache for all mix environments
					// Must be protected from concurrent access
					depsCache: {
						contents: engine.#CacheDir & {
							id: "\(app)_deps"
							concurrency: "locked"
						}
						dest: "/app/deps"
					}
				}
			},
			// 4. Build!
			docker.#Run & {
			script: "mix do deps.compile, compile"
			"env": MIX_ENV: env
                                mounts: {
					// Access deps cache readonly
                                        depsCache: {
                                                contents: engine.#CacheDir & {
                                                        id: "\(app)_deps"
							concurrency: "readonly"
                                                }
                                                dest: "/app/deps"
                                        }
                                        // Env-specific build cache
                                        buildCache: {
                                                contents: engine.#CacheDir & {
                                                        id: "\(app)_build_\(env)"
                                                        concurrency: "locked"
                                                }
                                                dest: "/app/_build/\(env)"
                                        }
                                }
                        },
			// 5. Set image config
			// FIXME: how does this actually work? Does it mutate the field? Or is the field somehow
			// prevented from being concrete? And if so, how?
			docker.#Set & {
				workdir: "/app"
				"env": MIX_ENV: env				
			}
                ]
        }
}


/////////////////
/////////////////
/////////////////

app:                dagger.#Artifact
prod_dockerfile:    string
docker_host:        string
dockerhub_username: string
dockerhub_password: dagger.#Secret
// Keep this in sync with ../docker/Dockerfile.production
runtime_image_ref: dagger.#Input & {string | *"thechangelog/runtime:2021-05-29T10.17.12Z"}
prod_image_ref:    dagger.#Input & {string | *"thechangelog/changelog.com:dagger"}
build_version:     dagger.#Input & {string}
git_sha:           dagger.#Input & {string}
git_author:        dagger.#Input & {string}
app_version:       dagger.#Input & {string}
build_url:         dagger.#Input & {string}
// Keep this in sync with manifests/changelog/db.yml
test_db_image_ref:      dagger.#Input & {string | *"circleci/postgres:12.6"}
test_db_container_name: "changelog_test_postgres"
run_test:               dagger.#Input & {bool}

// STORY #######################################################################
//
// 1. Migrate from CircleCI to GitHub Actions
//    - extract existing build pipeline into Dagger
//    - run the pipeline locally
//    - run the pipeline in GitHub Actions
//
// 2. Pipeline is up to 9x quicker (40s vs 370s)
//    - optimistic branching, as pipelines were originally intended
//    - use our own hardware - Linode g6-dedicated-8
//    - predictable runs, no queuing
//    - caching is buildkit layers
//
// 3. Open Telemetry integration out-of-the-box
//    - visualise all steps in Jaeger UI

// CI PIPELINE OVERVIEW ########################################################
//
//                  deps_compile_test      deps_compile_dev  /--- deps_compile_prod
//                  |                      |                 |    |
//                  v                      v                 |    v
//                  test_cache             assets_dev        |    image_prod_cache
//                  |                      |                 |    |
//                  v                      v                 |    |
// test_db_start -> test -> test_db_stop   assets_prod <-----/    |
//                  |                      |                      |
//                  |                      v                      |
//                  |                      image_prod <-----------/
//
//....................................... TODO .................................
//                  |                      |
//                  |                      v
//                  \--------------------> image_prod_digest
//
// ========================== BEFORE | AFTER | CHANGE ===================================
// Test, build & push           370s |   40s |  9.25x | https://app.circleci.com/pipelines/github/thechangelog/changelog.com/520/workflows/fbb7c701-d25a-42c1-b42c-db514cd770b4
// + app compile                220s |  150s |  1.46x | https://app.circleci.com/pipelines/github/thechangelog/changelog.com/582/workflows/65500f3d-eccc-49da-9ab0-69846bc812a7
// + deps compile               480s |  190s |  2.52x | https://app.circleci.com/pipelines/github/thechangelog/changelog.com/532/workflows/94f5a339-52a1-45ba-b39b-1bbb69ed6488
//
// Uncached                     ???s |  465s | ?.??x  |
//
// #############################################################################



app_image: docker.#Pull & {
	from: runtime_image_ref
}

// Put app source in the correct path, /app
deps: os.#Container & {
	image: app_image
	copy: {
		"/app": from: app
	}
}

// https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#run---mounttypecache
deps_mount: "--mount=type=cache,id=deps,target=/app/deps/,sharing=locked"

build_dev_mount:  "--mount=type=cache,id=build_dev,target=/app/_build/dev,sharing=locked"
build_test_mount: "--mount=type=cache,id=build_test,target=/app/_build/test,sharing=locked"
build_prod_mount: "--mount=type=cache,id=build_prod,target=/app/_build/prod,sharing=locked"

node_modules_mount: "--mount=type=cache,id=assets_node_modules,target=/app/assets/node_modules,sharing=locked"

#deps_compile: docker.#Build & {
	source:     deps
	dockerfile: """
		FROM \(runtime_image_ref)
		ARG MIX_ENV
		ENV MIX_ENV=$MIX_ENV
		COPY /app/ /app/
		WORKDIR /app

		RUN \(deps_mount) \(build_dev_mount) \(build_test_mount) \(build_prod_mount) mix do deps.get, deps.compile, compile
	"""
}

deps_compile_test: #deps_compile & {
	args: {
		MIX_ENV: "test"
	}
}

// Copy deps so that we can run tests in an os.#Container, not docker.#Build
test_cache: docker.#Build & {
	source:     deps_compile_test
	dockerfile: """
		FROM \(runtime_image_ref)
		ARG MIX_ENV
		ENV MIX_ENV=$MIX_ENV
		COPY /app/ /app/
		WORKDIR /app
		RUN --mount=type=cache,id=deps,target=/mnt/app/deps,sharing=locked cp -Rp /mnt/app/deps/* /app/deps/
		RUN --mount=type=cache,id=build_test,target=/mnt/app/_build/test,sharing=locked cp -Rp /mnt/app/_build/test/* /app/_build/test/
		"""
}

test: os.#Container & {
	always: run_test
	image:  test_cache
	env: {
		MIX_ENV: "test"
	}
	command: "mix test"
	dir:     "/app"
}

test_db_stop: docker.#Command & {
	host: docker_host
	env: {
		DEP:            test.env.MIX_ENV
		CONTAINER_NAME: test_db_container_name
	}
	command: #"""
		docker container stop $CONTAINER_NAME
		"""#
}

deps_compile_dev: #deps_compile & {
	args: {
		MIX_ENV: "dev"
	}
}

assets_dev: docker.#Build & {
	source:     deps_compile_dev
	dockerfile: """
		FROM \(runtime_image_ref)
		COPY /app/ /app/
		WORKDIR /app/assets

		RUN \(deps_mount) \(build_dev_mount) \(node_modules_mount) yarn install --frozen-lockfile && yarn run compile
	"""
}

deps_compile_prod: #deps_compile & {
	args: {
		MIX_ENV: "prod"
	}
}

assets_prod: docker.#Build & {
	source:     assets_dev
	dockerfile: """
		FROM \(runtime_image_ref)
		COPY /app/ /app/
		ENV MIX_ENV=prod
		WORKDIR /app/

		RUN \(deps_mount) \(build_prod_mount) \(node_modules_mount) mix phx.digest
	"""
}

image_prod_cache: docker.#Build & {
	source:     deps_compile_prod
	dockerfile: """
			FROM \(runtime_image_ref)
			COPY /app/ /app/
			WORKDIR /app
			RUN --mount=type=cache,id=deps,target=/mnt/app/deps,sharing=locked cp -Rp /mnt/app/deps/* /app/deps/
			RUN --mount=type=cache,id=build_prod,target=/mnt/app/_build/prod,sharing=locked cp -Rp /mnt/app/_build/prod/* /app/_build/prod/
		"""
}

image_prod: docker.#Command & {
	host: docker_host
	copy: {
		"/tmp/app": from: os.#Dir & {
			from: image_prod_cache
			path: "/app"
		}

		"/tmp/app/priv/static": from: os.#Dir & {
			from: assets_prod
			path: "/app/priv/static"
		}
	}
	env: {
		GIT_AUTHOR:         git_author
		GIT_SHA:            git_sha
		APP_VERSION:        app_version
		BUILD_VERSION:      build_version
		BUILD_URL:          build_url
		DOCKERHUB_USERNAME: dockerhub_username
		PROD_IMAGE_REF:     prod_image_ref
	}
	files: "/tmp/Dockerfile":                  prod_dockerfile
	secret: "/run/secrets/dockerhub_password": dockerhub_password
	command: #"""
		cd /tmp
		docker build --build-arg GIT_AUTHOR="$GIT_AUTHOR" --build-arg GIT_SHA="$GIT_SHA" --build-arg APP_VERSION="$APP_VERSION" --build-arg BUILD_URL="$BUILD_URL" --tag "$PROD_IMAGE_REF" .
		docker login --username "$DOCKERHUB_USERNAME" --password "$(cat /run/secrets/dockerhub_password)"
		docker push "$PROD_IMAGE_REF" | tee docker.push.log
		echo "$PROD_IMAGE_REF" > image.ref
		awk '/digest/ { print $3 }' < docker.push.log > image.digest
		"""#
}
