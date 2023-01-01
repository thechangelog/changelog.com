// Yarn is a package manager for Javascript applications
package yarn

import (
	"strings"

	"dagger.io/dagger"
	"dagger.io/dagger/engine"

	"universe.dagger.io/alpine"
	"universe.dagger.io/bash"
)

// Build a Yarn package
#Build: {
	// Application source code
	source: dagger.#FS

	// working directory to use
	cwd: *"." | string

	// Write the contents of `environment` to this file,
	// in the "envfile" format
	writeEnvFile: string | *""

	// Read build output from this directory
	// (path must be relative to working directory)
	buildDir: string | *"build"

	// Run this yarn script
	script: string | *"build"

	// Fix for shadowing issues
	let yarnScript = script

	// Cache to use, passed by the caller
	cache: engine.#CacheDir

	// Optional arguments for the script
	args: [...string] | *[]

	// Secret variables
	// FIXME: not implemented. Are they needed?
	secrets: [string]: dagger.#Secret

	// FIXME: Yarn's version depends on Alpine's version
	// Yarn version
	// yarnVersion: *"=~1.22" | string

	// FIXME: custom base image not supported
	image: alpine.#Build & {
		packages: {
			bash: {}
			yarn: {}
		}
	}

	// Run yarn in a containerized build environment
	command: bash.#Run & {
		// FIXME: not working?
		// *{
		//  _image: alpine.#Build & {
		//   packages: {
		//    bash: version: "=~5.1"
		//    yarn: version: yarnVersion
		//   }
		//  }

		//  image: _image.output
		//  env: CUSTOM_IMAGE: "0"
		// } | {
		//  env: CUSTOM_IMAGE: "1"
		// }

		"image": image.output

		script: #"""
			# Create $ENVFILE_NAME file if set
			[ -n "$ENVFILE_NAME" ] && echo "$ENVFILE" > "$ENVFILE_NAME"

			yarn --cwd "$YARN_CWD" install --production false

			opts=( $(echo $YARN_ARGS) )
			yarn --cwd "$YARN_CWD" run "$YARN_BUILD_SCRIPT" ${opts[@]}
			mv "$YARN_BUILD_DIRECTORY" /build
			"""#

		mounts: {
			"yarn cache": {
				dest:     "/cache/yarn"
				contents: cache
			}
			"package source": {
				dest:     "/src"
				contents: source
			}
			// FIXME: mount secrets
		}

		export: directories: "/build": _

		env: {
			YARN_BUILD_SCRIPT:    yarnScript
			YARN_ARGS:            strings.Join(args, "\n")
			YARN_CACHE_FOLDER:    "/cache/yarn"
			YARN_CWD:             cwd
			YARN_BUILD_DIRECTORY: buildDir
			if writeEnvFile != "" {
				ENVFILE_NAME: writeEnvFile
				ENVFILE:      strings.Join([ for k, v in env {"\(k)=\(v)"}], "\n")
			}
		}

		workdir: "/src"
	}

	// The final contents of the package after build
	output: command.export.directories."/build".contents
}
