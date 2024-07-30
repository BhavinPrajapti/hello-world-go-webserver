package main

import (
	"fmt"
	"log"
	"net/http"
)

// helloWorldHandler responds with "Hello World" to any HTTP request.
func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World")
}

// healthCheckHandler logs and responds to liveness probe requests.
func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Liveness probe hit")
	fmt.Fprintln(w, "OK")
}

// readinessCheckHandler logs and responds to readiness probe requests.
func readinessCheckHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Readiness probe hit")
	fmt.Fprintln(w, "OK")
}

func main() {
	// Register the helloWorldHandler to handle requests to the root URL path.
	http.HandleFunc("/", helloWorldHandler)

	// Register handlers for liveness and readiness probes.
	http.HandleFunc("/health", healthCheckHandler)
	http.HandleFunc("/ready", readinessCheckHandler)

	// Print a message indicating the server is starting on port 8080.
	log.Println("Starting server at port 8080")

	// Start the HTTP server on port 8080 and log any errors if the server fails to start.
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Error starting server: %s\n", err)
	}
}
