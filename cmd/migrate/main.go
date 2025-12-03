package main

import (
	"database/sql"
	"embed"
	"log"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib" // Import pgx driver for database/sql
	"github.com/pressly/goose/v3"
)

//go:embed ../../sql/schema/*.sql
var embedMigrations embed.FS

func main() {
	dbString := os.Getenv("DATABASE_URL")
	if dbString == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	db, err := sql.Open("pgx", dbString)
	if err != nil {
		log.Fatalf("Failed to open db: %v", err)
	}
	defer db.Close()

	// Setup Goose to use the embedded files
	goose.SetBaseFS(embedMigrations)

	if err := goose.SetDialect("postgres"); err != nil {
		log.Fatal(err)
	}

	// Run migrations
	if err := goose.Up(db, "sql/schema"); err != nil {
		log.Fatalf("Migration failed: %v", err)
	}

	log.Println("Migrations applied successfully!")
}
