package main

import (
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("I guess it's working."))
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
