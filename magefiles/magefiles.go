//go:build mage
// +build mage

package main

import (
	"context"
	"os"

	"dagger.io/dagger"
	"github.com/thechangelog/changelog.com/magefiles/sysexit"

	"github.com/magefile/mage/mg"
	"github.com/thechangelog/changelog.com/magefiles/image"
)

// Run the CI pipeline
func CI(ctx context.Context) {
	mg.SerialCtxDeps(ctx, Image.Runtime, Test, Image.Production)
}

// Run the CD pipeline
func CD(ctx context.Context) {
	mg.SerialCtxDeps(ctx, Fly.Deploy)
}

type Image mg.Namespace

// Build & publish the runtime image
func (Image) Runtime(ctx context.Context) {
	defer sysexit.Handle()

	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		panic(sysexit.Unavailable(err))
	}
	defer dag.Close()

	image.New(ctx, dag).Pipeline("runtime").
		Runtime().
		PublishRuntime()
}

// Build & publish the production image
func (Image) Production(ctx context.Context) {
	defer sysexit.Handle()

	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		panic(sysexit.Unavailable(err))
	}
	defer dag.Close()

	image.New(ctx, dag).Pipeline("prod").
		ProductionClean().
		PublishProduction()
}

// Run tests
func Test(ctx context.Context) {
	defer sysexit.Handle()
	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		panic(sysexit.Unavailable(err))
	}
	defer dag.Close()

	testImage := image.New(ctx, dag).Pipeline("test")

	_, err = testImage.TestContainer().
		WithExec([]string{
			"mix", "test",
		}).
		ExitCode(ctx)

	if err != nil {
		panic(sysexit.Data(err))
	}
}

type Fly mg.Namespace

// Push app container image to Fly.io
func (Fly) Deploy(ctx context.Context) {
	defer sysexit.Handle()

	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		panic(sysexit.Unavailable(err))
	}
	defer dag.Close()

	image.New(ctx, dag).Pipeline("deploy").
		Deploy().
		OK()
}
