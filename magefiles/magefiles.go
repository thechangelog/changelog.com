//go:build mage
// +build mage

package main

import (
	"context"

	"github.com/magefile/mage/mg"
	//mage:import
	"github.com/thechangelog/changelog.com/magefiles/daggerV01"
	//mage:import
	"github.com/thechangelog/changelog.com/magefiles/image"
)

// Run the entire CI pipeline
func CI(ctx context.Context) {
	mg.SerialCtxDeps(ctx, image.Image.Runtime, daggerV01.DaggerV01.Shipit)
}
