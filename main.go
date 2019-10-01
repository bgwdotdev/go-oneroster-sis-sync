package main

import (
	"github.com/fffnite/go-oneroster-sis-sync/internal/sync"
	sis "github.com/fffnite/go-oneroster-sis-sync/internal/wcbs-pass"
	"github.com/gchaincl/dotsql"
	log "github.com/sirupsen/logrus"
	flag "github.com/spf13/pflag"
	"github.com/spf13/viper"
	"os"
)

func main() {
	flag.Parse()
	cs := viper.GetString("sqlconnstring")
	db := sync.ConnectSql(cs)
	defer db.Close()

	fp := viper.GetString("sql_file_path")
	dot, err := dotsql.LoadFromFile(fp)
	if err != nil {
		log.Error(err)
		os.Exit(1)
	}
	token := sync.PostLogin()
	sis.RunBuild(db, dot, token)
}

// setup envs
func init() {
	viper.SetEnvPrefix("goors")

	flag.StringP(
		"sqlConnectionUrl",
		"s",
		"",
		"sql server connection url (required)",
	)
	viper.BindPFlag("sqlconnstring", flag.Lookup("sqlConnectionUrl"))
	viper.BindEnv("sqlconnstring")
	cd := "sqlserver://sa:Passw0rd@rmanjaro:1400?database=passtrains&connection+timeout=30"
	viper.SetDefault("sqlconnstring", cd)

	flag.StringP(
		"sql-file-path",
		"p",
		"",
		"Sql query file path (required)",
	)
	viper.BindPFlag("sql_file_path", flag.Lookup("sql-file-path"))
	viper.BindEnv("sql_file_path")
	fd := "./sqlQueries/"
	viper.SetDefault("sql_file_path", fd)

	flag.StringP(
		"sis-academic-year",
		"y",
		"",
		"The academic year of sis to pull (required)",
	)
	viper.BindPFlag("sis_academic_year", flag.Lookup("sis-academic-year"))
	viper.BindEnv("sis_academic_year")

	flag.StringP(
		"sis-last-modified",
		"m",
		"2000-01-01",
		"Filter anything after last modified date",
	)
	viper.BindPFlag("sis_last_modified", flag.Lookup("sis-last-modified"))
	viper.BindEnv("sis_last_modified")

	flag.StringP(
		"or-api-url",
		"u",
		"localhost:3000",
		"The URL of the oneroster API (required)",
	)
	viper.BindPFlag("api_url", flag.Lookup("or-api-url"))
	viper.BindEnv("api_url")

	flag.StringP(
		"or-api-ci",
		"U",
		"",
		"The client ID of the oauth2 oneroster API (required)",
	)
	viper.BindPFlag("api_ci", flag.Lookup("or-api-ci"))
	viper.BindEnv("api_ci")

	flag.StringP(
		"or-api-cs",
		"P",
		"",
		"The Client Secret of the ouath2 oneroster API (required)",
	)
	viper.BindPFlag("api_cs", flag.Lookup("or-api-cs"))
	viper.BindEnv("api_cs")

}
