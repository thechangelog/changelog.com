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
	defer sysexit.Handle()

	dag, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	mustBeAvailable(err)
	defer dag.Close()

	ctx = context.WithValue(ctx, "dag", dag)
	mg.CtxDeps(ctx, Image.Runtime, Test, Image.Production)
}

// Run the CD pipeline
func CD(ctx context.Context) {
	mg.CtxDeps(ctx, Fly.Deploy)
}

type Image mg.Namespace

// Build & publish the runtime image
func (Image) Runtime(ctx context.Context) {
	defer sysexit.Handle()

	var dag *dagger.Client
	var err error
	dag, ok := ctx.Value("dag").(*dagger.Client)
	if !ok {
		dag, err = dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
		mustBeAvailable(err)
		defer dag.Close()
	}

	image.New(ctx, dag.Pipeline("📦 RUNTIME IMAGE")).
		Runtime().
		PublishRuntime()
}

// Build & publish the production image
func (Image) Production(ctx context.Context) {
	defer sysexit.Handle()

	var dag *dagger.Client
	var err error
	dag, ok := ctx.Value("dag").(*dagger.Client)
	if !ok {
		dag, err = dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
		mustBeAvailable(err)
		defer dag.Close()
	}

	image.New(ctx, dag.Pipeline("🎁 PRODUCTION IMAGE")).
		ProductionClean().
		PublishProduction()
}

// Run tests
func Test(ctx context.Context) {
	defer sysexit.Handle()

	var dag *dagger.Client
	var err error
	dag, ok := ctx.Value("dag").(*dagger.Client)
	if !ok {
		dag, err = dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
		mustBeAvailable(err)
		defer dag.Close()
	}

	image.New(ctx, dag.Pipeline("🧰 TEST")).Test()
}

type Fly mg.Namespace

// Push app container image to Fly.io
func (Fly) Deploy(ctx context.Context) {
	defer sysexit.Handle()

	var dag *dagger.Client
	var err error
	dag, ok := ctx.Value("dag").(*dagger.Client)
	if !ok {
		dag, err = dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
		mustBeAvailable(err)
		defer dag.Close()
	}

	image.New(ctx, dag.Pipeline("🏁 DEPLOY")).Deploy()
}

// Start Dagger Engine on Fly.io
func (Fly) DaggerStart(ctx context.Context) {
	defer sysexit.Handle()

	var dag *dagger.Client
	var err error
	dag, ok := ctx.Value("dag").(*dagger.Client)
	if !ok {
		dag, err = dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
		mustBeAvailable(err)
		defer dag.Close()
	}

	image.New(ctx, dag.Pipeline("🚙 START DAGGER ENGINE")).DaggerStart()
}

// Stop Dagger Engine on Fly.io
func (Fly) DaggerStop(ctx context.Context) {
	defer sysexit.Handle()

	var dag *dagger.Client
	var err error
	dag, ok := ctx.Value("dag").(*dagger.Client)
	if !ok {
		dag, err = dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
		mustBeAvailable(err)
		defer dag.Close()
	}

	image.New(ctx, dag.Pipeline("🚗 STOP DAGGER ENGINE")).DaggerStop()
}

func mustBeAvailable(err error) {
	if err != nil {
		panic(sysexit.Unavailable(err))
	}
}
