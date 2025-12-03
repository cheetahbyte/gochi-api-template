package service

import (
	"context"

	"github.com/username/module/internal/repository"
)

type TodoService struct {
	repo *repository.Queries
}

func NewTodoService(repo *repository.Queries) *TodoService {
	return &TodoService{repo: repo}
}

func (s *TodoService) Create(ctx context.Context, title string) (repository.Todo, error) {
	return s.repo.CreateTodo(ctx, repository.CreateTodoParams{
		Title:     title,
		Completed: false,
	})
}

func (s *TodoService) List(ctx context.Context) ([]repository.Todo, error) {
	return s.repo.ListTodos(ctx)
}

func (s *TodoService) Get(ctx context.Context, id int64) (repository.Todo, error) {
	return s.repo.GetTodo(ctx, id)
}
