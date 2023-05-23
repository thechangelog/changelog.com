package image

import (
	"fmt"

	"dagger.io/dagger"
)

const (
	postgreSQLUser = "postgres"
	postgreSQLPass = "postgres"
)

func (image *Image) WithPostgreSQL(dbName string) *Image {
	postgresqlContainerName := fmt.Sprintf("%s_postgres", dbName)

	image.container = image.container.
		WithServiceBinding(postgresqlContainerName, image.postgreSQLContainer(dbName)).
		WithEnvVariable("DB_HOST", postgresqlContainerName).
		WithEnvVariable("DB_NAME", dbName).
		WithEnvVariable("DB_USER", postgreSQLUser).
		WithEnvVariable("DB_PASS", postgreSQLPass)

	return image
}

func (image *Image) postgreSQLContainer(dbName string) *dagger.Container {
	return image.NewContainer().
		From(fmt.Sprintf("postgres:%s", image.versions.Postgres())).
		WithExposedPort(5432).
		WithEnvVariable("POSTGRES_USER", postgreSQLUser).
		WithEnvVariable("POSTGRES_PASSWORD", postgreSQLPass).
		WithEnvVariable("POSTGRES_DB", dbName).
		WithExec(nil)
}
