package sync

import (
	"database/sql"
	_ "github.com/denisenkom/go-mssqldb"
	log "github.com/sirupsen/logrus"
	"os"
)

// Connects to the sql instance
func ConnectSql(connString string) *sql.DB {
	db, err := sql.Open("sqlserver", connString)
	if err != nil {
		log.Error(err)
		os.Exit(1)
	}
	err = db.Ping()
	if err != nil {
		log.Error(err)
		os.Exit(1)
	}
	return db
}
