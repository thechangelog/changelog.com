package sysexit

import (
	"fmt"
	"os"
)

type SysExit struct {
	Code  int
	Error error
}

func Handle() {
	if e := recover(); e != nil {
		if exit, ok := e.(SysExit); ok == true {
			fmt.Fprintf(os.Stderr, "%s\nsysexits(3) error code %d\n", exit.Error.Error(), exit.Code)
			os.Exit(exit.Code)
		}
		panic(e) // not an Exit, pass-through
	}
}

// https://man.openbsd.org/sysexits
// TODO: https://pkg.go.dev/github.com/sean-/sysexits
func Unavailable(err error) SysExit {
	return SysExit{Code: 69, Error: err}
}

func Os(err error) SysExit {
	return SysExit{Code: 71, Error: err}
}

func File(err error) SysExit {
	return SysExit{Code: 72, Error: err}
}

func Create(err error) SysExit {
	return SysExit{Code: 73, Error: err}
}
