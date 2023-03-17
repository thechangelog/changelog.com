package image

import (
	"dagger.io/dagger"
)

func (image *Image) TestContainer() *dagger.Container {
	return image.
		Runtime().
		WithAppSrc().
		WithTestEnv().
		WithAppDeps().
		WithPostgreSQL("changelog_test").
		OK().
		container
}

func (image *Image) WithTestEnv() *Image {
	image.container = image.container.
		WithEnvVariable("MIX_ENV", "test")

	return image
}
