package env

import (
	"context"
	"fmt"

	"dagger.io/dagger"
)

func HostEnv(ctx context.Context, host *dagger.Host, varName string) *dagger.HostVariable {
	hostEnv := host.EnvVariable(varName)
	hostEnvVal, err := hostEnv.Value(ctx)
	if err != nil {
		panic(err)
	}
	if hostEnvVal == "" {
		fmt.Printf("⚠️  %s env var is not set - should it?\n", varName)
	}
	return hostEnv
}

func Val(ctx context.Context, hostEnv *dagger.HostVariable) string {
	val, err := hostEnv.Value(ctx)
	if err != nil {
		panic(err)
	}
	return val
}

func SecretVal(ctx context.Context, hostEnv *dagger.Secret) string {
	val, err := hostEnv.Plaintext(ctx)
	if err != nil {
		panic(err)
	}
	return val
}
