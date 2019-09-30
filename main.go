package main

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"fmt"
	sq "github.com/Masterminds/squirrel"
	_ "github.com/denisenkom/go-mssqldb"
	or "github.com/fffnite/go-oneroster/ormodel"
	"github.com/gchaincl/dotsql"
	log "github.com/sirupsen/logrus"
	flag "github.com/spf13/pflag"
	"github.com/spf13/viper"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
)

func main() {
	var db *sql.DB
	flag.Parse()
	cs := viper.GetString("sqlconnstring")
	db = connectSql(cs)
	defer db.Close()

	fp := viper.GetString("sql_file_path")
	dot, err := dotsql.LoadFromFile(fp)
	if err != nil {
		log.Error(err)
	}
	classes := buildClasses(db, dot)
	// TODO: remove/debug only
	o, err := json.Marshal(classes)
	if err != nil {
		log.Error(err)
	}
	fmt.Println(string(o))
	token := postLogin()
	for _, v := range classes {
		putData(v, "/classes/"+v.SourcedId, token)
	}
}

func postLogin() string {
	response, err := http.PostForm(
		(viper.GetString("api_url") + "/login"),
		url.Values{
			"clientid":     {viper.GetString("api_ci")},
			"clientsecret": {viper.GetString("api_cs")},
		},
	)
	if err != nil {
		log.Error(err)
	}
	defer response.Body.Close()
	token, err := ioutil.ReadAll(response.Body)
	if err != nil {
		log.Error(err)
	}
	log.Debug(string(token))
	return string(token)
}

func putData(data interface{}, endpoint, token string) {
	json, err := json.Marshal(data)
	if err != nil {
		log.Error(err)
	}
	url := viper.GetString("api_url") + endpoint
	req, err := http.NewRequest(
		"PUT",
		url,
		bytes.NewBuffer(json),
	)
	// remove special characters from "token"\n -- implementation error?
	t := token[1 : len(token)-2]
	bearer := "Bearer " + t
	req.Header.Add("Authorization", bearer)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Error(err)
	}
	b, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Error(err)
	}
	log.Info(string(b))
}

func buildClasses(db *sql.DB, dot *dotsql.DotSql) []or.Classes {
	rows, err := dot.Query(db, "select-classes-scheduled", viper.Get("sis_academic_year"))
	if err != nil {
		log.Error(err)
	}
	var classes []or.Classes
	for rows.Next() {
		var j or.Classes
		var course or.Nested
		var org or.Nested
		var subjects string
		err = rows.Scan(
			&j.SourcedId,
			&j.Status,
			&j.DateLastModified,
			&j.Title,
			&course.SourcedId,
			&j.ClassCode,
			&j.ClassType,
			&j.Location,
			&org.SourcedId,
			&subjects,
		)
		if err != nil {
			log.Error(err)
		}
		course.Type = "course"
		j.Course = &course
		org.Type = "org"
		j.School = &org
		j.Subjects = append(j.Subjects, subjects)
		termRows, err := dot.Query(
			db,
			"select-classes-scheduled-terms",
			viper.Get("sis_academic_year"),
			j.SourcedId,
		)
		if err != nil {
			log.Error(err)
		}
		j.Terms = subQuery(termRows, "academicSessions")
		classes = append(classes, j)
	}
	return classes
}

func subQuery(rows *sql.Rows, oType string) []*or.Nested {
	var nest []*or.Nested
	for rows.Next() {
		var nested or.Nested
		nested.Type = oType
		err := rows.Scan(&nested.SourcedId)
		if err != nil {
			log.Error(err)
		}
		nest = append(nest, &nested)
	}
	return nest
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
		"2003",
		"The academic year of sis to pull (required)",
	)
	viper.BindPFlag("sis_academic_year", flag.Lookup("sis-academic-year"))
	viper.BindEnv("sis_academic_year")

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

// Connects to the sql instance
func connectSql(connString string) *sql.DB {
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
