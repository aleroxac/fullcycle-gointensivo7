package entity

import (
	"errors"

	"github.com/aleroxac/fullcycle-gointensivo7/pkg/entity"
)

// type Book struct {
// 	ID                int
// 	Title             string
// 	Author            string
// 	Genres            []string
// 	Topic             string
// 	Subject           string
// 	PageNumber        int
// 	PublicationDate   time.Time
// 	PublicationFormat string
// 	Languages         []string
// 	ISBN10            string
// 	ISBN13            string
// 	Stars             map[string]float64
// }

type Book struct {
	ID     entity.ID
	Title  string
	Author string
	Genre  string
}

func NewBook(id int, title string, author string, genre string) (*Book, error) {
	book := &Book{
		ID:     entity.NewID(),
		Title:  title,
		Author: author,
		Genre:  genre,
	}
	err := book.IsValid()
	if err != nil {
		return nil, err
	}
	return book, nil
}

func (b *Book) IsValid() error {
	if b.ID.String() == "" {
		return errors.New("invalid id")
	}
	if b.Title == "" {
		return errors.New("invalid title")
	}
	if b.Author == "" {
		return errors.New("invalid author")
	}
	if b.Genre == "" {
		return errors.New("invalid genre")
	}
	return nil
}
