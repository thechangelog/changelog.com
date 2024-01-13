package image

import (
	"context"
	"fmt"

	"dagger.io/dagger"
	"github.com/thechangelog/changelog.com/magefiles/env"
	"github.com/thechangelog/changelog.com/magefiles/sysexit"
	"github.com/thechangelog/changelog.com/magefiles/tools"
)

const (
	RuntimePlatform    = "linux/amd64"
	RuntimePlatformAlt = "linux-x64"

	RootRepository = "thechangelog/changelog.com"
	MainBranch     = "master"
)

type Image struct {
	ctx       context.Context
	dag       *dagger.Client
	container *dagger.Container
	versions  *tools.Versions
}

func New(ctx context.Context, dag *dagger.Client) *Image {
	image := &Image{ctx: ctx, dag: dag}
	image.container = image.NewContainer()
	image.versions = tools.CurrentVersions()
	return image
}

func (image *Image) NewContainer() *dagger.Container {
	return image.dag.Container(dagger.ContainerOpts{Platform: RuntimePlatform}).
		WithEnvVariable("DEBIAN_FRONTEND", "noninteractive").
		WithEnvVariable("TERM", "xterm-256color")
}

func (image *Image) Pipeline(name string) *Image {
	image.container = image.container.Pipeline(name)

	return image
}

func (image *Image) OK() *Image {
	_, err := image.container.ExitCode(image.ctx)
	mustCreate(err)

	return image
}

func (image *Image) Env(key string) *env.Env {
	return env.Get(image.ctx, image.dag.Host(), key)
}

func (image *Image) Publish(reference string) *Image {
	registryUsername := image.Env("GHCR_USERNAME")
	if registryUsername.Value() == "" {
		fmt.Printf(
			"\n👮 Skip publishing %s\n"+
				"👮 GHCR_USERNAME env var is required to publish this image\n",
			reference,
		)
		return image
	}

	registryPassword := image.Env("GHCR_PASSWORD")
	if registryPassword.Value() == "" {
		fmt.Printf(
			"\n👮 Skip publishing %s\n"+
				"👮 GHCR_PASSWORD env var is required to publish this image\n",
			reference,
		)
		return image
	}

	githubRepo := image.Env("GITHUB_REPOSITORY")
	githubRef := image.Env("GITHUB_REF_NAME")

	if githubRepo.Value() != RootRepository {
		fmt.Printf("\n👮 Publishing only runs on %s repo\n", RootRepository)
		return image
	}

	if githubRef.Value() != MainBranch {
		fmt.Printf("\n👮 Publishing only runs on %s branch\n", MainBranch)
		return image
	}

	_, err := image.
		WithRegistryAuth().
		container.Publish(image.ctx, reference, dagger.ContainerPublishOpts{
		MediaTypes: dagger.Dockermediatypes,
	})
	mustCreate(err)

	return image
}

func (image *Image) WithRegistryAuth() *Image {
	image.container = image.container.
		WithRegistryAuth(
			"ghcr.io",
			image.Env("GHCR_USERNAME").Value(),
			image.Env("GHCR_PASSWORD").Secret(),
		)

	return image
}

func mustCreate(err error) {
	if err != nil {
		panic(sysexit.Create(err))
	}
}
