package docker

import (
	"dagger.io/dagger"
	"dagger.io/dagger/engine"
)

// Modular build API for Docker containers
#Build: {
	steps: [#Step, ...#Step]
	output: #Image

	// Generate build DAG from linerar steps
	_dag: {
		for idx, step in steps {
			"\(idx)": step & {
				// connect input to previous output
				if idx > 0 {
					// FIXME: the intermediary `output` is needed because of a possible CUE bug.
					// `._dag."0".output: 1 errors in empty disjunction::`
					// See: https://github.com/cue-lang/cue/issues/1446
					// input: _dag["\(idx-1)"].output
					_output: _dag["\(idx-1)"].output
					input:   _output
				}
			}
		}
	}

	if len(_dag) > 0 {
		output: _dag["\(len(_dag)-1)"].output
	}
}

// A build step is anything that produces a docker image
#Step: {
	input?: #Image
	output: #Image
	...
}

// Build step that copies files into the container image
#Copy: {
	input:    #Image
	contents: dagger.#FS
	source:   string | *"/"
	dest:     string | *"/"

	// Execute copy operation
	_copy: engine.#Copy & {
		"input": input.rootfs
		"source": {
			root: contents
			path: source
		}
		"dest": dest
	}

	output: #Image & {
		config: input.config
		rootfs: _copy.output
	}
}

// Build step that executes a Dockerfile
#Dockerfile: {
	// Source directory
	source: dagger.#FS

	// FIXME: not yet implemented
	*{
		// Look for Dockerfile in source at default path
		path: "Dockerfile"
	} | {
		// Look for Dockerfile in source at a custom path
		path: string
	} | {
		// Custom dockerfile  contents
		contents: string
	}
}
