package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	_, err := http.Get(fmt.Sprintf("http://127.0.0.1:%s%s", os.Getenv("HEALTHCHECK_PATH"), os.Getenv("HEALTHCHECK_PORT")))
	if err != nil {
		os.Exit(1)
	}
}
