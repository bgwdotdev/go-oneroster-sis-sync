package main

import (
	"database/sql"
	"fmt"
	sq "github.com/Masterminds/squirrel"
	_ "github.com/denisenkom/go-mssqldb"
	log "github.com/sirupsen/logrus"
	flag "github.com/spf13/pflag"
	"github.com/spf13/viper"
	"os"
)

var sqlConnectionUrl string

func main() {
	var db *sql.DB
	flag.Parse()
	cs := viper.GetString("sqlconnstring")
	db = connectSql(cs)
	defer db.Close()
	sampleQuery(db)
}

// setup envs
func init() {
	viper.SetEnvPrefix("goors")

	flag.StringVarP(
		&sqlConnectionUrl,
		"sqlConnectionUrl",
		"s",
		"",
		"sql server connection url (required)",
	)

	viper.BindPFlag("sqlconnstring", flag.Lookup("sqlConnectionUrl"))
	viper.BindEnv("sqlconnstring")
	cd := "sqlserver://sa:Passw0rd@rmanjaro:1400?database=passtrains&connection+timeout=30"
	viper.SetDefault("sqlconnstring", cd)
}

// Connects to the sql instance
func connectSql(connString string) *sql.DB {
	// TODO: remove default?

	db, err := sql.Open("sqlserver", connString)
	if err != nil {
		log.Error(err)
		os.Exit(1)
	}
	return db
}

// Test function
func sampleQuery(db *sql.DB) {
	rows, err := sq.
		Select("*").
		From("dbo.school").
		RunWith(db).
		Query()
	if err != nil {
		log.Error(err)
	}
	for rows.Next() {
		fmt.Println(rows)
	}
}
