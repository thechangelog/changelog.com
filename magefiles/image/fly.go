package image

import (
	"fmt"

	"dagger.io/dagger"
)

func (image *Image) Deploy() *Image {
	githubRepo := image.Env("GITHUB_REPOSITORY")
	githubRef := image.Env("GITHUB_REF_NAME")

	fmt.Printf("🔍 githubRepo: %s\n", githubRepo.Value())
	fmt.Printf("🔍 githubRef: %s\n", githubRef.Value())

	image = image.flyctl()

	if githubRepo.Value() != RootRepository {
		fmt.Printf("\n👮 Deploys only run on %s repo\n", RootRepository)
		return image
	}

	if githubRef.Value() != MainBranch {
		fmt.Printf("\n👮 Deploys only run on %s branch\n", MainBranch)
		return image
	}

	image.container = image.container.
		WithExec([]string{
			"status",
		}).
		WithExec([]string{
			"deploy",
			"--image", image.ProductionImageRef(),
		})

	return image.OK()
}

func (image *Image) flyctl() *Image {
	image.container = image.NewContainer().
		From(image.flyctlImageRef()).
		WithSecretVariable("FLY_API_TOKEN", image.Env("FLY_API_TOKEN").Secret()).
		WithMountedFile("fly.toml", image.flyConfig()).
		WithExec([]string{
			"version",
		})

	return image
}

func (image *Image) flyctlImageRef() string {
	return fmt.Sprintf("flyio/flyctl:v%s", image.versions.Flyctl())
}

func (image *Image) flyConfig() *dagger.File {
	return image.dag.Host().Directory("2022.fly").File("fly.toml")
}
