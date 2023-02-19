package daggerV01

import (
	"context"
	"os"

	"dagger.io/dagger"
	"github.com/magefile/mage/mg"
	"github.com/thechangelog/changelog.com/magefiles/docker"
	"github.com/thechangelog/changelog.com/magefiles/env"
	"github.com/thechangelog/changelog.com/magefiles/sysexit"
)

type DaggerV01 mg.Namespace

// Build, test & publish using dagger v0.1 pipeline
func (DaggerV01) Shipit(ctx context.Context) {
	defer sysexit.Handle()

	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		panic(sysexit.Unavailable(err))
	}
	defer dag.Close()

	ShipIt(ctx, dag)
}

func ShipIt(ctx context.Context, dag *dagger.Client) {
	user := env.Get(ctx, dag.Host(), "USER")

	daggerLogLevel := env.Get(ctx, dag.Host(), "DAGGER_LOG_LEVEL")
	daggerLogFormat := env.Get(ctx, dag.Host(), "DAGGER_LOG_FORMAT")

	dockerhubUsername := env.Get(ctx, dag.Host(), "DOCKERHUB_USERNAME")
	dockerhubPassword := env.Get(ctx, dag.Host(), "DOCKERHUB_PASSWORD")

	githubRepository := env.Get(ctx, dag.Host(), "GITHUB_REPOSITORY")
	githubRunID := env.Get(ctx, dag.Host(), "GITHUB_RUN_ID")
	githubRefName := env.Get(ctx, dag.Host(), "GITHUB_REF_NAME")
	githubSHA := env.Get(ctx, dag.Host(), "GITHUB_SHA")

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
			"mix.exs",
			"mix.lock",
		},
		Exclude: []string{
			"**/node_modules",
		},
	})

	_, err := docker.Container(ctx, dag).
		Pipeline("dagger v0.1").
		WithEnvVariable("USER", user.Value()).
		WithEnvVariable("GITHUB_REPOSITORY", githubRepository.Value()).
		WithEnvVariable("GITHUB_RUN_ID", githubRunID.Value()).
		WithEnvVariable("GITHUB_REF_NAME", githubRefName.Value()).
		WithEnvVariable("GITHUB_SHA", githubSHA.Value()).
		WithEnvVariable("DAGGER_LOG_LEVEL", daggerLogLevel.Value()).
		WithEnvVariable("DAGGER_LOG_FORMAT", daggerLogFormat.Value()).
		WithEnvVariable("DOCKERHUB_USERNAME", dockerhubUsername.Value()).
		WithSecretVariable("DOCKERHUB_PASSWORD", dockerhubPassword.Secret()).
		WithDirectory("/app", app).
		WithWorkdir("/app").
		WithExec([]string{
			"make", "--directory=2021.dagger", "ship-it",
		}).
		ExitCode(ctx)

	if err != nil {
		panic(sysexit.Unavailable(err))
	}
}
