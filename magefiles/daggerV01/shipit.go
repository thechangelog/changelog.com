package daggerV01

import (
	"context"
	"os"

	"dagger.io/dagger"
	"github.com/magefile/mage/mg"
	"github.com/thechangelog/changelog.com/magefiles/docker"
	"github.com/thechangelog/changelog.com/magefiles/env"
)

type DaggerV01 mg.Namespace

// Build, test & publish using dagger v0.1 pipeline
func (t DaggerV01) Shipit(ctx context.Context) error {
	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		return err
	}
	defer dag.Close()

	return ShipIt(ctx, dag)
}

func ShipIt(ctx context.Context, dag *dagger.Client) error {
	user := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "USER"))

	daggerLogLevel := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "DAGGER_LOG_LEVEL"))
	daggerLogFormat := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "DAGGER_LOG_FORMAT"))

	dockerhubUsername := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "DOCKERHUB_USERNAME"))
	dockerhubPassword := env.HostEnv(ctx, dag.Host(), "DOCKERHUB_PASSWORD").Secret()

	githubRepository := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "GITHUB_REPOSITORY"))
	githubRunID := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "GITHUB_RUN_ID"))
	githubRefName := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "GITHUB_REF_NAME"))
	githubSHA := env.Val(ctx, env.HostEnv(ctx, dag.Host(), "GITHUB_SHA"))

	app := dag.Host().Directory(".", dagger.HostDirectoryOpts{
		Include: []string{
			".git",
			"2021.dagger",
			"assets",
			"config",
			"docker",
			"lib",
			"priv",
			"test",
			".dockerignore",
			"Makefile",
			"mix.exs",
			"mix.lock",
		},
		Exclude: []string{
			"**/node_modules",
		},
	})

	_, err := docker.Container(ctx, dag).
		WithEnvVariable("USER", user).
		WithEnvVariable("GITHUB_REPOSITORY", githubRepository).
		WithEnvVariable("GITHUB_RUN_ID", githubRunID).
		WithEnvVariable("GITHUB_REF_NAME", githubRefName).
		WithEnvVariable("GITHUB_SHA", githubSHA).
		WithEnvVariable("DAGGER_LOG_LEVEL", daggerLogLevel).
		WithEnvVariable("DAGGER_LOG_FORMAT", daggerLogFormat).
		WithEnvVariable("DOCKERHUB_USERNAME", dockerhubUsername).
		WithSecretVariable("DOCKERHUB_PASSWORD", dockerhubPassword).
		WithDirectory("/app", app).
		WithWorkdir("/app").
		WithExec([]string{
			"make", "--directory=2021.dagger", "ship-it",
		}).
		ExitCode(ctx)

	return err
}
