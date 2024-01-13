package image

import (
	"fmt"
	"time"
)

func (image *Image) Deploy() *Image {
	githubRepo := image.Env("GITHUB_REPOSITORY")
	githubRef := image.Env("GITHUB_REF_NAME")

	fmt.Printf("🔍 githubRepo: %s\n", githubRepo.Value())
	fmt.Printf("🔍 githubRef: %s\n", githubRef.Value())

	image = image.flyctl().app()

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
			"--vm-size", "performance-4x",
		})

	return image.OK()
}

func (image *Image) DaggerStart() *Image {
	image = image.flyctl().dagger()
	var err error

	primaryEngineMachineID := image.Env("FLY_PRIMARY_DAGGER_ENGINE_MACHINE_ID").Value()
	if primaryEngineMachineID == "" {
		fmt.Printf(
			"👮 Skip starting Dagger Engine, FLY_PRIMARY_ENGINE_MACHINE_ID env var is missing\n",
		)
		return image
	}

	image, err = image.startMachine(primaryEngineMachineID)
	if err != nil {
		secondaryEngineMachineID := image.Env("FLY_SECONDARY_DAGGER_ENGINE_MACHINE_ID").Value()
		if secondaryEngineMachineID == "" {
			fmt.Printf(
				"👮 Skip starting Dagger Engine, FLY_SECONDARY_DAGGER_ENGINE_MACHINE_ID env var is missing\n",
			)
			return image
		}

		image, err = image.startMachine(secondaryEngineMachineID)
		mustCreate(err)
	}

	return image
}

func (image *Image) DaggerStop() *Image {
	image = image.flyctl().dagger()
	var err error

	primaryEngineMachineID := image.Env("FLY_PRIMARY_DAGGER_ENGINE_MACHINE_ID").Value()
	if primaryEngineMachineID == "" {
		fmt.Printf(
			"👮 Skip stopping Dagger Engine, FLY_PRIMARY_ENGINE_MACHINE_ID env var is missing\n",
		)
		return image
	}

	image, err = image.stopMachine(primaryEngineMachineID)
	if err != nil {
		secondaryEngineMachineID := image.Env("FLY_SECONDARY_DAGGER_ENGINE_MACHINE_ID").Value()
		if secondaryEngineMachineID == "" {
			fmt.Printf(
				"👮 Skip stopping Dagger Engine, FLY_SECONDARY_DAGGER_ENGINE_MACHINE_ID env var is missing\n",
			)
			return image
		}

		image, err = image.stopMachine(secondaryEngineMachineID)
		mustCreate(err)
	}

	return image
}

func (image *Image) flyctl() *Image {
	image.container = image.NewContainer().
		From(image.flyctlImageRef()).
		WithSecretVariable("FLY_API_TOKEN", image.Env("FLY_API_TOKEN").Secret()).
		WithEnvVariable("CACHE_BUSTED_AT", time.Now().String()).
		WithExec([]string{
			"version",
		})

	return image
}

func (image *Image) app() *Image {
	image.container = image.container.
		WithMountedFile("fly.toml", image.dag.Host().Directory("fly.io/changelog-2024-01-12").File("fly.toml"))

	return image
}

func (image *Image) dagger() *Image {
	image.container = image.container.
		WithMountedFile("fly.toml", image.dag.Host().Directory("fly.io/dagger-engine-2023-05-20").File("fly.toml"))

	return image
}

func (image *Image) startMachine(id string) (*Image, error) {
	var err error

	image.container, err = image.container.
		WithExec([]string{
			"machine",
			"start", id,
		}).
		WithExec([]string{
			"machine",
			"status", id,
		}).
		Sync(image.ctx)

	return image, err
}

func (image *Image) stopMachine(id string) (*Image, error) {
	var err error

	image.container, err = image.container.
		WithExec([]string{
			"machine",
			"stop", id,
		}).
		WithExec([]string{
			"machine",
			"status", id,
		}).
		Sync(image.ctx)

	return image, err
}

func (image *Image) flyctlImageRef() string {
	return fmt.Sprintf("flyio/flyctl:v%s", image.versions.Flyctl())
}
