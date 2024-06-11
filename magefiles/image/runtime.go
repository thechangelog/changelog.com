package image

import (
	"fmt"
)

const (
	RepositoryURL = "https://github.com/thechangelog/changelog.com"
)

func (image *Image) RuntimeImageRef() string {
	imageOwner := image.Env("IMAGE_OWNER").Value()
	if imageOwner == "" {
		imageOwner = image.Env("GITHUB_ACTOR").Value()
	}
	// If we are not running in CI,
	// and there is no explicit IMAGE_OWNER,
	// default to thechangelog,
	// otherwise the image reference will be invalid.
	if imageOwner == "" {
		imageOwner = "thechangelog"
	}

	return fmt.Sprintf(
		"ghcr.io/%s/changelog-runtime:elixir-v%s-erlang-v%s-nodejs-v%s",
		imageOwner,
		image.versions.Elixir(),
		image.versions.Erlang(),
		image.versions.Nodejs(),
	)
}

func (image *Image) PublishRuntime() *Image {
	return image.
		WithRuntimeLabels().
		Publish(image.RuntimeImageRef())
}

func (image *Image) WithRuntimeLabels() *Image {
	description := fmt.Sprintf(
		"💜 Elixir v%s | 🚜 Erlang v%s | ⬢ Node.js v%s | 🗃️ Ubuntu %s | %s",
		image.versions.Elixir(),
		image.versions.Erlang(),
		image.versions.Nodejs(),
		image.versions.Ubuntu.Long,
		buildURL(),
	)

	image.container = image.container.
		WithLabel("org.opencontainers.image.description", description).
		WithLabel("org.opencontainers.image.source", RepositoryURL)

	return image
}

// This image is the used by all other environments: dev, test & prod
// It is published as https://github.com/thechangelog/changelog.com/pkgs/container/changelog-runtime
func (image *Image) Runtime() *Image {
	return image.
		Elixir().
		WithAptPackages().
		WithGit().
		WithImagemagick().
		WithCmarkPrerequisites().
		WithInotifyTools().
		WithPostgreSQLClient().
		WithNodejs().
		WithYarn().
		OK()
}

func (image *Image) Elixir() *Image {
	image.container = image.NewContainer().
		From(image.ElixirImageRef()).
		WithExec([]string{
			"mix", "--version",
		}).
		WithExec([]string{
			"echo", "Install local rebar...",
		}).
		WithExec([]string{
			"mix", "local.rebar", "--force",
		}).
		WithExec([]string{
			"echo", "Install local hex...",
		}).
		WithExec([]string{
			"mix", "local.hex", "--force",
		})

	return image
}

func (image *Image) ElixirImageRef() string {
	return fmt.Sprintf(
		"hexpm/elixir:%s-erlang-%s-ubuntu-%s",
		image.versions.Elixir(),
		image.versions.Erlang(),
		image.versions.Ubuntu.Short,
	)
}

func (image *Image) WithAptPackages() *Image {
	image.container = image.container.
		WithExec([]string{
			"echo", "Locate apt packages...",
		}).
		WithExec([]string{
			"apt-get", "update",
		})

	return image
}

func (image *Image) WithGit() *Image {
	image.container = image.container.
		WithExec([]string{
			"apt-get", "install", "--yes", "git-core",
		}).
		WithExec([]string{
			"git", "--version",
		})

	return image
}

func (image *Image) WithImagemagick() *Image {
	image.container = image.container.
		WithExec([]string{
			"echo", "Install convert (imagemagick), required for image resizing to work...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "imagemagick",
		}).
		WithExec([]string{
			"convert", "--version",
		})

	return image
}

// https://hexdocs.pm/cmark/readme.html#prerequisites
func (image *Image) WithCmarkPrerequisites() *Image {
	image.container = image.container.
		WithExec([]string{
			"echo", "Install gcc (build-essential), required to install cmark...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "build-essential",
		}).
		WithExec([]string{
			"gcc", "--version",
		})

	return image
}

func (image *Image) WithInotifyTools() *Image {
	image.container = image.container.
		WithExec([]string{
			"echo", "Install inotify-tools for dynamic website reloads while developing...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "inotify-tools",
		}).
		WithExec([]string{
			"which", "inotifywatch",
		})

	return image
}

func (image *Image) WithOnePassword() *Image {
	op := image.NewContainer().
		From(fmt.Sprintf("1password/op:%s", image.versions.OnePassword())).
		File("/usr/local/bin/op")

	image.container = image.container.
		WithFile("/usr/local/bin/op", op).
		WithExec([]string{
			"op", "--version",
		})

	return image
}

func (image *Image) WithPostgreSQLClient() *Image {
	image.container = image.container.
		WithExec([]string{
			"echo", "Install postgresql-client for manual commands while developing...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "postgresql-client",
		}).
		WithExec([]string{
			"psql", "--version",
		})

	return image
}

func (image *Image) WithNodejs() *Image {
	NodejsVersionAndPlatform := fmt.Sprintf("node-v%s-%s", image.versions.Nodejs(), RuntimePlatformAlt)
	image.container = image.WithCurl().WithXZ().container.
		WithExec([]string{
			"echo", "Install Node.js...",
		}).
		WithExec([]string{
			"curl", "--silent", "--fail", "--location",
			"--output", fmt.Sprintf("/opt/%s.tar.xz", NodejsVersionAndPlatform),
			fmt.Sprintf("https://nodejs.org/dist/v%s/%s.tar.xz", image.versions.Nodejs(), NodejsVersionAndPlatform),
		}).
		WithExec([]string{
			"tar", "-xJf", fmt.Sprintf("/opt/%s.tar.xz", NodejsVersionAndPlatform), "-C", "/opt",
		}).
		WithEnvVariable("PATH", fmt.Sprintf("/opt/%s/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", NodejsVersionAndPlatform)).
		WithExec([]string{
			"node", "--version",
		}).
		WithExec([]string{
			"npm", "--version",
		})

	return image
}

func (image *Image) WithCurl() *Image {
	image.container = image.container.
		WithExec([]string{
			"apt-get", "install", "--yes", "curl",
		}).
		WithExec([]string{
			"curl", "--version",
		})

	return image
}

func (image *Image) WithXZ() *Image {
	image.container = image.container.
		WithExec([]string{
			"apt-get", "install", "--yes", "xz-utils",
		}).
		WithExec([]string{
			"xz", "--version",
		})

	return image
}

func (image *Image) WithYarn() *Image {
	image.container = image.container.
		WithExec([]string{
			"npm", "install", "--global", fmt.Sprintf("yarn@%s", image.versions.Yarn()),
		}).
		WithExec([]string{
			"yarn", "--version",
		})

	return image
}
