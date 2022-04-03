package main

import (
    "fmt"
    "embed"
    "html/template"
    "log"
    "net/http"
    "os"
    "strings"
)

//go:embed templates/*
var resources embed.FS

var t = template.Must(template.ParseFS(resources, "templates/*"))

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        data := map[string]string{
            "Header": fmt.Sprintf("%#v", r.Header),
            "Host": r.Host,
            "Method": r.Method,
            "PublicIp": os.Getenv("FLY_PUBLIC_IP"),
            "Region": os.Getenv("FLY_REGION"),
            "RemoteAddr": r.RemoteAddr,
            "URL": r.URL.Redacted(),
        }
        for header, values := range r.Header {
          data[strings.Replace(header, "-", "", -1)] = strings.Join(values, ", ")
        }

        t.ExecuteTemplate(w, "index.html.tmpl", data)
    })

    log.Println("listening on", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
