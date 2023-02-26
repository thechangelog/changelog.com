package docker

import (
	"context"
	"os"

	"dagger.io/dagger"
)

const (
	// https://hub.docker.com/_/docker/tags?page=1&name=cli
	Image = "docker:23.0.0-cli-alpine3.17"
)

func Container(ctx context.Context, dag *dagger.Client) *dagger.Container {
	dockerContainer := dag.Container().
		From(Image).
		WithExec([]string{
			"apk", "add", "bash", "curl", "git", "make",
		})

	_, err := os.Stat("/var/run/docker.sock")
	if err == nil {
		dockerContainer = dockerContainer.
			WithUnixSocket("/var/run/docker.sock", dag.Host().UnixSocket("/var/run/docker.sock"))
	}

	dockerHostEnv := os.Getenv("DOCKER_HOST")
	if dockerHostEnv != "" {
		dockerContainer = dockerContainer.
			WithEnvVariable("DOCKER_HOST", dockerHostEnv)
	}

	return dockerContainer
}
