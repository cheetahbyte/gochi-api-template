package domain

import (
	"context"

	"github.com/username/module/internal/repository"
)

type TodoRepository interface {
	GetByID(ctx context.Context, id int64) (*repository.Todo, error)
	Create(ctx context.Context, todo *repository.Todo) error
	List(ctx context.Context) ([]repository.Todo, error)
}

type TodoService interface {
	CreateTodo(ctx context.Context, title string) (*repository.Todo, error)
	MarkComplete(ctx context.Context, id int64) error
	GetTodo(ctx context.Context, id int64) (*repository.Todo, error)
}
