package main

import (
	"context"
	"fmt"
	"time"

	neon "github.com/kislerdm/neon-sdk-go"
)

type Changelog struct {
	// +private
	Verbose bool
}

func New(
	// +optional
	// Adds more detail to the output, recommended in combination with --progress=plain
	verbose string,
) *Changelog {
	module := &Changelog{}
	if verbose != "" {
		module.Verbose = true
	}
	return module
}

// Create a db branch on Neon.tech and return the connection string
//
// Example usage: dagger call db-branch --neon-api-key=env:NEON_API_KEY [--branch=BRANCH-NAME]
func (c *Changelog) DbBranch(
	ctx context.Context,
	// See https://neon.tech/docs/manage/api-keys
	neonApiKey *Secret,
	//+optional
	// Project name, defaults to orange-sound-86604986
	project string,
	//+optional
	// Branch name, defaults to dev-YYYY-MM-DD
	branch string,
) (string, error) {
	if project == "" {
		project = "orange-sound-86604986"
	}

	if branch == "" {
		branch = fmt.Sprintf("dev-%s", time.Now().Format("2006-01-02"))
	}

	apiKey, err := neonApiKey.Plaintext(ctx)
	if err != nil {
		return "", err
	}

	n, err := neon.NewClient(neon.Config{Key: apiKey})
	minComputeUnit := neon.ComputeUnit(1.0)
	maxComputeUnit := neon.ComputeUnit(2.0)
	createdBranch, err := n.CreateProjectBranch(project, &neon.BranchCreateRequest{
		Branch: &neon.BranchCreateRequestBranch{
			Name: &branch,
		},
		Endpoints: &[]neon.BranchCreateRequestEndpointOptions{
			{
				AutoscalingLimitMinCu: &minComputeUnit,
				AutoscalingLimitMaxCu: &maxComputeUnit,
				Type:                  neon.EndpointType("read_write"),
			},
		},
	})
	if err != nil {
		return "", err
	}

	if c.Verbose {
		fmt.Printf("CREATED_BRANCH: %+v\n", createdBranch)
	}

	db := "changelog"
	host := createdBranch.EndpointsResponse.Endpoints[0].Host
	role := "changelog-2023-12-09"
	rolePassword, err := n.GetProjectBranchRolePassword(project, createdBranch.Branch.ID, role)
	if err != nil {
		return "", err
	}

	if c.Verbose {
		fmt.Printf("PASS: %+v\n", rolePassword)
	}

	appEnv := fmt.Sprintf(`
Before starting the app, run the following in order to use the new db branch:

export DB_NAME='%s'
export DB_HOST='%s'
export DB_USER='%s'
export DB_PASS='%s'`, db, host, role, rolePassword.Password)

	return appEnv, nil
}
