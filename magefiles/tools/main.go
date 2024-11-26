package tools

import (
	"bufio"
	"os"
	"path/filepath"
	"strings"

	"github.com/thechangelog/changelog.com/magefiles/sysexit"
)

type Ubuntu struct {
	Short string
	Long  string
}

type Versions struct {
	toolVersions map[string]string
	Ubuntu       Ubuntu
}

func CurrentVersions() *Versions {
	return &Versions{
		toolVersions: toolVersions(),
		Ubuntu: Ubuntu{
			// https://hub.docker.com/r/hexpm/elixir/tags?page=1&ordering=last_updated&name=ubuntu-noble
			Short: "noble-20240429",
			Long:  "24.04 LTS (Noble Numbat)",
		},
	}
}

// https://github.com/elixir-lang/elixir/releases
// asdf list all elixir
func (v *Versions) Elixir() string {
	return v.toolVersions["elixir"]
}

// https://github.com/erlang/otp/releases
// asdf list all erlang
func (v *Versions) Erlang() string {
	return v.toolVersions["erlang"]
}

// https://nodejs.org/en/download/releases
// asdf list all nodejs
func (v *Versions) Nodejs() string {
	return v.toolVersions["nodejs"]
}

// https://www.postgresql.org/docs/release
// asdf list all postgres
func (v *Versions) Postgres() string {
	return v.toolVersions["postgres"]
}

// https://github.com/yarnpkg/yarn/releases
// asdf list all yarn
func (v *Versions) Yarn() string {
	return v.toolVersions["yarn"]
}

// https://github.com/superfly/flyctl/releases
// asdf list all flyctl
func (v *Versions) Flyctl() string {
	return v.toolVersions["flyctl"]
}

// https://app-updates.agilebits.com/product_history/CLI2
// asdf list all 1password-cli
func (v *Versions) OnePassword() string {
	return v.toolVersions["1password-cli"]
}

func toolVersions() map[string]string {
	wd, err := os.Getwd()
	if err != nil {
		panic(sysexit.Os(err))
	}
	versions, err := os.Open(filepath.Join(wd, ".tool-versions"))
	if err != nil {
		panic(sysexit.File(err))
	}
	toolVersions := make(map[string]string)
	scanner := bufio.NewScanner(versions)
	for scanner.Scan() {
		line := scanner.Text()
		toolAndVersion := strings.Split(line, " ")
		toolVersions[toolAndVersion[0]] = toolAndVersion[1]
	}

	return toolVersions
}
