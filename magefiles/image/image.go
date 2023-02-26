package image

import (
	"context"
	"fmt"
	"os"

	"dagger.io/dagger"
	"github.com/magefile/mage/mg"
	"github.com/thechangelog/changelog.com/magefiles/env"
	"github.com/thechangelog/changelog.com/magefiles/sysexit"
)

const (
	// https://hub.docker.com/r/hexpm/elixir/tags?page=1&ordering=last_updated&name=ubuntu-jammy
	ElixirVersion      = "1.14.2"
	ErlangVersion      = "25.1"
	UbuntuVersionShort = "jammy-20220428"
	UbuntuVersionLong  = "22.04 LTS (Jammy Jellyfish)"

	// https://nodejs.org/en/download/releases/
	NodejsVersion = "14.21.1"

	RuntimePlatform    = "linux/amd64"
	RuntimePlatformAlt = "linux-x64"
)

func ElixirImageRef() string {
	return fmt.Sprintf("hexpm/elixir:%s-erlang-%s-ubuntu-%s", ElixirVersion, ErlangVersion, UbuntuVersionShort)
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

	build := &Build{
		ctx:       ctx,
		dag:       dag,
		container: dag.Container(dagger.ContainerOpts{Platform: RuntimePlatform}).Pipeline("image"),
	}

	build.
		Elixir().
		WithAptPackages().
		WithGit().
		WithImagemagick().
		WithCmarkPrerequisites().
		WithInotifyTools().
		WithPostgreSQLClient().
		WithNodejs().
		WithYarn().
		OK().
		Publish()
}

type Build struct {
	ctx       context.Context
	dag       *dagger.Client
	container *dagger.Container
}

func (build *Build) Elixir() *Build {
	build.container = build.container.
		From(ElixirImageRef()).
		WithUser("root").
		WithEnvVariable("DEBIAN_FRONTEND", "noninteractive").
		WithEnvVariable("TERM", "xterm-256color").
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

	return build
}

func (build *Build) WithAptPackages() *Build {
	build.container = build.container.
		WithExec([]string{
			"echo", "Locate apt packages...",
		}).
		WithExec([]string{
			"apt-get", "update",
		})

	return build
}

func (build *Build) WithImagemagick() *Build {
	build.container = build.container.
		WithExec([]string{
			"echo", "Install convert (imagemagick), required for image resizing to work...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "imagemagick",
		}).
		WithExec([]string{
			"convert", "--version",
		})

	return build
}

// https://hexdocs.pm/cmark/readme.html#prerequisites
func (build *Build) WithCmarkPrerequisites() *Build {
	build.container = build.container.
		WithExec([]string{
			"echo", "Install gcc (build-essential), required to install cmark...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "build-essential",
		}).
		WithExec([]string{
			"gcc", "--version",
		})

	return build
}

func (build *Build) WithCurl() *Build {
	build.container = build.container.
		WithExec([]string{
			"apt-get", "install", "--yes", "curl",
		}).
		WithExec([]string{
			"curl", "--version",
		})

	return build
}

func (build *Build) WithXZ() *Build {
	build.container = build.container.
		WithExec([]string{
			"apt-get", "install", "--yes", "xz-utils",
		}).
		WithExec([]string{
			"xz", "--version",
		})

	return build
}

func (build *Build) WithGit() *Build {
	build.container = build.container.
		WithExec([]string{
			"apt-get", "install", "--yes", "git-core",
		}).
		WithExec([]string{
			"git", "--version",
		})

	return build
}

func (build *Build) WithNodejs() *Build {
	NodejsVersionAndPlatform := fmt.Sprintf("node-v%s-%s", NodejsVersion, RuntimePlatformAlt)
	build.container = build.WithCurl().WithXZ().container.
		WithExec([]string{
			"echo", "Install Node.js...",
		}).
		WithExec([]string{
			"curl", "--silent", "--fail", "--location",
			"--output", fmt.Sprintf("/opt/%s.tar.xz", NodejsVersionAndPlatform),
			fmt.Sprintf("https://nodejs.org/dist/v%s/%s.tar.xz", NodejsVersion, NodejsVersionAndPlatform),
		}).
		WithExec([]string{
			"tar", "-xJvf", fmt.Sprintf("/opt/%s.tar.xz", NodejsVersionAndPlatform), "-C", "/opt",
		}).
		WithEnvVariable("PATH", fmt.Sprintf("/opt/%s/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", NodejsVersionAndPlatform)).
		WithExec([]string{
			"node", "--version",
		}).
		WithExec([]string{
			"npm", "--version",
		}).
		WithExec([]string{
			"rm", fmt.Sprintf("/opt/%s.tar.xz", NodejsVersionAndPlatform),
		})

	return build
}

func (build *Build) WithYarn() *Build {
	build.container = build.container.
		WithExec([]string{
			"npm", "install", "--global", "yarn",
		}).
		WithExec([]string{
			"yarn", "--version",
		})

	return build
}

func (build *Build) WithInotifyTools() *Build {
	build.container = build.container.
		WithExec([]string{
			"echo", "Install inotify-tools for dynamic website reloads while developing...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "inotify-tools",
		}).
		WithExec([]string{
			"which", "inotifywatch",
		})

	return build
}

func (build *Build) WithPostgreSQLClient() *Build {
	build.container = build.container.
		WithExec([]string{
			"echo", "Install postgresql-client for manual commands while developing...",
		}).
		WithExec([]string{
			"apt-get", "install", "--yes", "postgresql-client",
		}).
		WithExec([]string{
			"psql", "--version",
		})

	return build
}

func (build *Build) OK() *Build {
	_, err := build.container.ExitCode(build.ctx)
	if err != nil {
		panic(sysexit.Unavailable(err))
	}

	return build
}

func (build *Build) RuntimeImageRef() string {
	imageOwner := build.Env("IMAGE_OWNER")
	if imageOwner.Value() == "" {
		imageOwner = build.Env("GITHUB_ACTOR")
	}

	return fmt.Sprintf(
		"ghcr.io/%s/changelog-runtime:elixir-v%s-erlang-v%s-nodejs-v%s",
		imageOwner.Value(),
		ElixirVersion,
		ErlangVersion,
		NodejsVersion,
	)
}

func (build *Build) Env(key string) *env.Env {
	return env.Get(build.ctx, build.dag.Host(), key)
}

func (build *Build) WithLabels() *Build {
	description := fmt.Sprintf(
		"💜 Elixir v%s | 🚜 Erlang v%s | ⬢ Node.js v%s | 🐡 Ubuntu %s",
		ElixirVersion,
		ErlangVersion,
		NodejsVersion,
		UbuntuVersionLong,
	)

	build.container = build.container.
		WithLabel("org.opencontainers.image.description", description).
		WithLabel("org.opencontainers.image.source", "https://github.com/thechangelog/changelog.com")

	return build
}

func (build *Build) Publish() *Build {
	registryPassword := build.Env("GHCR_PASSWORD")
	if registryPassword.Value() == "" {
		fmt.Printf(
			"\n👮 Skip publishing %s\n"+
				"👮 GHCR_PASSWORD env var is required to publish this image\n",
			build.RuntimeImageRef(),
		)
		return build
	}

	_, err := build.
		WithRegistryAuth().
		WithLabels().
		container.Publish(build.ctx, build.RuntimeImageRef())
	if err != nil {
		panic(sysexit.Create(err))
	}

	return build
}

func (build *Build) WithRegistryAuth() *Build {
	build.container = build.container.
		WithRegistryAuth(
			"ghcr.io",
			build.Env("GHCR_USERNAME").Value(),
			build.Env("GHCR_PASSWORD").Secret(),
		)

	return build
}
