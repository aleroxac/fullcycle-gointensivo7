package service

import (
	"database/sql"
	"errors"
	"fmt"
	"time"

	"github.com/aleroxac/fullcycle-gointensivo7/internal/entity"
)

type BookService struct {
	db *sql.DB
}

func NewBookService(db *sql.DB) *BookService {
	return &BookService{db: db}
}

func (s *BookService) CreateBook(book *entity.Book) error {
	query := "INSERT INTO books (title, author, genre) VALUES ($1, $2, $3)"
	_, err := s.db.Exec(query, book.Title, book.Author, book.Genre)
	if err != nil {
		fmt.Println("create-book-error:", err)
		return err
	}

	return nil
}

func (s *BookService) GetBooks() ([]entity.Book, error) {
	query := "SELECT id, title, author, genre FROM books"
	rows, err := s.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var books []entity.Book
	for rows.Next() {
		var book entity.Book
		if err := rows.Scan(&book.ID, &book.Title, &book.Author, &book.Genre); err != nil {
			return nil, err
		}
		books = append(books, book)
	}

	return books, nil
}

func (s *BookService) GetBookByID(id int) (*entity.Book, error) {
	query := "SELECT id, title, author, genre FROM books WHERE id = $1"
	row := s.db.QueryRow(query, id)

	var book entity.Book
	if err := row.Scan(&book.ID, &book.Title, &book.Author, &book.Genre); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, nil
		}
		return nil, err
	}

	return &book, nil
}

func (s *BookService) UpdateBook(book *entity.Book) error {
	query := "UPDATE books SET title = $1, author = $2, genre = $3 WHERE id = $4"
	result, err := s.db.Exec(query, book.Title, book.Author, book.Genre, book.ID)

	fmt.Println("result:", result)
	fmt.Println("error:", err)

	return err
}

func (s *BookService) DeleteBook(id int) error {
	query := "DELETE FROM books WHERE id = $1"
	_, err := s.db.Exec(query, id)
	return err
}

func (s *BookService) SimulateReading(bookID int, duration time.Duration, results chan<- string) {
	book, err := s.GetBookByID(bookID)
	if err != nil || book == nil {
		results <- fmt.Sprintf("Livro com ID %d não encontrado.", bookID)
		return
	}

	time.Sleep(duration) // Simula o tempo de leitura.
	results <- fmt.Sprintf("Leitura do livro '%s' concluída!", book.Title)
}

func (s *BookService) SearchBooksByName(name string) ([]entity.Book, error) {
	query := "SELECT id, title, author, genre FROM books WHERE title LIKE ?"
	rows, err := s.db.Query(query, "%"+name+"%")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var books []entity.Book
	for rows.Next() {
		var book entity.Book
		if err := rows.Scan(&book.ID, &book.Title, &book.Author, &book.Genre); err != nil {
			return nil, err
		}
		books = append(books, book)
	}

	return books, nil
}

func (s *BookService) SimulateMultipleReadings(bookIDs []int, duration time.Duration) []string {
	results := make(chan string, len(bookIDs))

	for _, id := range bookIDs {
		go func(bookID int) {
			s.SimulateReading(bookID, duration, results)
		}(id)
	}

	var responses []string
	for range bookIDs {
		responses = append(responses, <-results)
	}
	close(results)

	return responses
}
