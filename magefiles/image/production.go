package image

import (
	"fmt"
	"os"

	"dagger.io/dagger"
	"github.com/magefile/mage/sh"
	"github.com/thechangelog/changelog.com/magefiles/env"
)

func (image *Image) Production() *Image {
	productionImage := image.Runtime().
		WithAppSrc().
		WithProdEnv().
		WithObanRepo().
		WithAppDeps().
		WithAppCompiled().
		WithAppStaticAssets().
		WithAppLegacyAssets().
		WithGitAuthor().
		WithGitSHA().
		WithBuildURL().
		OK()

	if os.Getenv("DEBUG") != "" {
		_, err := productionImage.container.Export(image.ctx, "tmp/app.test.prod.tar")
		mustCreate(err)
	}

	return productionImage
}

// ProductionClean() is a TEMPORARY function, until Elixir releases are implemented
// === WHY?
// Jerod Santo - 8:35 PM - Mar. 15th, 2023
// @gerhard hmm 5 failed ship it runs in a row…
// I don’t think this is sufferable much longer
// https://github.com/thechangelog/changelog.com/actions/runs/4430462525
func (image *Image) ProductionClean() *Image {
	if os.Getenv("OBAN_LICENSE_KEY") == "" {
		fmt.Printf("\n👮 Building the production image requires an OBAN_LICENSE_KEY\n")
		return image
	}
	if os.Getenv("OBAN_KEY_FINGERPRINT") == "" {
		fmt.Printf("\n👮 Building the production image requires an OBAN_KEY_FINGERPRINT\n")
		return image
	}
	app := image.Production().container.
		WithExec([]string{
			"cp", "--recursive", "--preserve=mode,ownership,timestamps", "/app", "/app.prod",
		}).
		// 👉 TODO: multiple arguments to rm -fr do not work as expected
		WithExec([]string{
			"rm", "-fr", "/app.prod/_build/test",
		}).
		WithExec([]string{
			"rm", "-fr", "/app.prod/assets",
		}).
		WithExec([]string{
			"rm", "-fr", "/app.prod/test",
		}).
		Directory("/app.prod")

	image = image.
		Elixir().
		WithAptPackages().
		WithGit().
		WithImagemagick().
		WithOnePassword().
		WithOnDeploy().
		WithAppStart().
		WithProdEnv()

	image.container = image.container.
		WithDirectory("/app", app).
		WithWorkdir("/app").
		WithExec([]string{
			"sh", "-c", "echo \"Ensure $MIX_ENV bytecode is present & OK...\"",
		}).
		WithExec([]string{
			"sh", "-c", "ls -lahd /app/_build/$MIX_ENV/lib/*/ebin",
		})

	image = image.OK()

	if os.Getenv("DEBUG") != "" {
		_, err := image.container.Export(image.ctx, "tmp/app.prod.tar")
		mustCreate(err)
	}

	return image
}

func (image *Image) PublishProduction() *Image {
	return image.
		WithProductionLabels().
		Publish(image.ProductionImageRef())
}

func (image *Image) WithProductionLabels() *Image {
	description := fmt.Sprintf(
		"🖥 %s",
		buildURL(),
	)

	image.container = image.container.
		WithLabel("org.opencontainers.image.description", description).
		WithLabel("org.opencontainers.image.source", RepositoryURL)

	return image
}

func (image *Image) ProductionImageRef() string {
	imageOwner := image.Env("IMAGE_OWNER")
	if imageOwner.Value() == "" {
		imageOwner = image.Env("GITHUB_ACTOR")
	}

	return fmt.Sprintf(
		"ghcr.io/%s/changelog-prod:%s",
		imageOwner.Value(),
		gitSHA(),
	)
}

func (image *Image) WithProdEnv() *Image {
	image.container = image.container.
		WithEnvVariable("MIX_ENV", "prod")

	return image
}

func (image *Image) WithObanRepo() *Image {
	OBAN_KEY_FINGERPRINT := env.Get(image.ctx, image.dag.Host(), "OBAN_KEY_FINGERPRINT").Secret()
	OBAN_LICENSE_KEY := env.Get(image.ctx, image.dag.Host(), "OBAN_LICENSE_KEY").Secret()
	image.container = image.container.
		WithSecretVariable("OBAN_KEY_FINGERPRINT", OBAN_KEY_FINGERPRINT).
		WithSecretVariable("OBAN_LICENSE_KEY", OBAN_LICENSE_KEY).
		WithExec([]string{
			"sh", "-c", "mix hex.repo add oban https://getoban.pro/repo --fetch-public-key $OBAN_KEY_FINGERPRINT --auth-key $OBAN_LICENSE_KEY",
		})

	return image.OK()
}

func (image *Image) WithGitAuthor() *Image {
	image.container = image.container.
		WithNewFile("COMMIT_USER", dagger.ContainerWithNewFileOpts{
			Contents:    gitAuthor(),
			Permissions: 444,
		})

	return image
}

func gitAuthor() string {
	author := os.Getenv("GITHUB_ACTOR")
	if author == "" {
		author = os.Getenv("USER")
	}

	return author
}

func (image *Image) WithGitSHA() *Image {
	image.container = image.container.
		WithNewFile("priv/static/version.txt", dagger.ContainerWithNewFileOpts{
			Contents:    gitSHA(),
			Permissions: 444,
		})

	return image
}

func gitSHA() string {
	gitSHA := os.Getenv("GITHUB_SHA")
	if gitSHA == "" {
		if gitHEAD, err := sh.Output("git", "rev-parse", "HEAD"); err == nil {
			gitSHA = fmt.Sprintf("%s.", gitHEAD)
		}
		gitSHA = fmt.Sprintf("%sdev", gitSHA)
	}

	return gitSHA
}

func (image *Image) WithBuildURL() *Image {
	image.container = image.container.
		WithNewFile("priv/static/build.txt", dagger.ContainerWithNewFileOpts{
			Contents:    buildURL(),
			Permissions: 444,
		})

	return image
}

func buildURL() string {
	githubServerURL := os.Getenv("GITHUB_SERVER_URL")
	githubRepository := os.Getenv("GITHUB_REPOSITORY")
	githubRunID := os.Getenv("GITHUB_RUN_ID")
	buildURL := fmt.Sprintf("%s/%s/actions/runs/%s", githubServerURL, githubRepository, githubRunID)

	if githubRunID == "" {
		if hostname, err := os.Hostname(); err == nil {
			buildURL = hostname
		}
		if cwd, err := os.Getwd(); err == nil {
			buildURL = fmt.Sprintf("%s:%s", buildURL, cwd)
		}
	}

	return buildURL
}
