package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aleroxac/fullcycle-gointensivo7/config"
	"github.com/aleroxac/fullcycle-gointensivo7/internal/cli"
	"github.com/aleroxac/fullcycle-gointensivo7/internal/service"
	"github.com/aleroxac/fullcycle-gointensivo7/internal/web"
	_ "github.com/lib/pq"
)

func main() {
	config, err := config.Load()
	if err != nil {
		log.Fatalf("failed to connect to the database: %v", err)
	}

	db, err := sql.Open(
		config.DatabaseDriver,
		fmt.Sprintf(
			"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
			config.DatabaseHost,
			config.DatabasePort,
			config.DatabaseUsername,
			config.DatabasePassword,
			config.DatabaseDBName,
		),
	)
	if err != nil {
		log.Fatalf("failed to connect to the database: %v", err)
	}
	err = db.Ping()
	if err != nil {
		log.Fatalf("failed to ping the database: %v", err)
	}
	defer db.Close()

	bookService := service.NewBookService(db)
	bookHandlers := web.NewBookHandlers(bookService)
	if len(os.Args) > 1 && (os.Args[1] == "search" || os.Args[1] == "simulate") {
		bookCLI := cli.NewBookCLI(bookService)
		bookCLI.Run()
		return
	}

	router := http.NewServeMux()
	router.HandleFunc("GET /books", bookHandlers.GetBooks)
	router.HandleFunc("POST /books", bookHandlers.CreateBook)
	router.HandleFunc("GET /books/{id}", bookHandlers.GetBookByID)
	router.HandleFunc("PUT /books/{id}", bookHandlers.UpdateBook)
	router.HandleFunc("DELETE /books/{id}", bookHandlers.DeleteBook)
	router.HandleFunc("POST /books/read", bookHandlers.SimulateReading)

	log.Printf("Server is running on port %s...", config.HTTP_PORT)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", config.HTTP_PORT), router))
}
