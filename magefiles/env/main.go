package env

import (
	"context"
	"fmt"

	"dagger.io/dagger"
)

type Env struct {
	ctx  context.Context
	host *dagger.Host
	name string
}

func Get(ctx context.Context, host *dagger.Host, name string) *Env {
	newEnv := &Env{
		ctx:  ctx,
		host: host,
		name: name,
	}

	if newEnv.Value() == "" {
		fmt.Printf("🤔 %s env var is not set - should it?\n", newEnv.name)
	}

	return newEnv
}

func (env *Env) Value() string {
	val, err := env.hostVariable().Value(env.ctx)
	if err != nil {
		panic(err)
	}
	return val
}

func (env *Env) Secret() *dagger.Secret {
	return env.hostVariable().Secret()
}

func (env *Env) hostVariable() *dagger.HostVariable {
	return env.host.EnvVariable(env.name)
}
