package image

func (image *Image) Test() *Image {
	return image.
		Runtime().
		WithAppSrc().
		WithAppDeps().
		WithTestEnv().
		WithAppCompiled().
		WithPostgreSQL("changelog_test").
		WithTest().
		OK()
}

func (image *Image) WithTestEnv() *Image {
	image.container = image.container.
		WithEnvVariable("MIX_ENV", "test")

	return image
}

func (image *Image) WithTest() *Image {
	image.container = image.container.
		WithExec([]string{
			"mix", "test",
		})

	return image
}
