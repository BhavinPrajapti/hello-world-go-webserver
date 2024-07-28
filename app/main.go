package main

import (
	"fmt"
	"net/http"
)

// helloWorldHandler responds with "Hello World" to any HTTP request.
func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello World")
}

func main() {

	// Register the helloWorldHandler to handle requests to the root URL path.
	http.HandleFunc("/", helloWorldHandler)

	// Print a message indicating the server is starting on port 8080.
	fmt.Println("Starting webserver...")

	// Start the HTTP server on port 8080 and log any errors if the server fails to start.
	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Printf("Error starting server: %s\n", err)
	}
}
