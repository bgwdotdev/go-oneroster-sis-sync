package pass

import (
	"database/sql"
	_ "github.com/denisenkom/go-mssqldb"
	or "github.com/fffnite/go-oneroster/ormodel"
	"github.com/gchaincl/dotsql"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

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

func BuildClasses(db *sql.DB, dot *dotsql.DotSql) []or.Classes {
	var classes []or.Classes
	c := []string{"select-classes-scheduled", "select-classes-homeroom"}
	for _, v := range c {
		rows, err := dot.Query(db, v, viper.Get("sis_academic_year"))
		if err != nil {
			log.Error(err)
		}
		for rows.Next() {
			var j or.Classes
			var course or.Nested
			var org or.Nested
			var grades string
			var subjects string
			var subjectCodes string
			var periods string
			err = rows.Scan(
				&j.SourcedId,
				&j.Status,
				&j.DateLastModified,
				&j.Title,
				&grades,
				&course.SourcedId,
				&j.ClassCode,
				&j.ClassType,
				&j.Location,
				&org.SourcedId,
				&subjects,
				&subjectCodes,
				&periods,
			)
			if err != nil {
				log.Error(err)
			}
			course.Type = "course"
			j.Course = &course
			org.Type = "org"
			j.School = &org
			if grades != "" {
				j.Grades = append(j.Grades, grades)
			}
			if subjects != "" {
				j.Subjects = append(j.Subjects, subjects)
			}
			if subjectCodes != "" {
				j.SubjectCodes = append(j.SubjectCodes, subjectCodes)
			}
			if periods != "" {
				j.Periods = append(j.Periods, periods)
			}

			termRows, err := dot.Query(
				db,
				(v + "-terms"),
				viper.Get("sis_academic_year"),
				j.SourcedId,
			)
			if err != nil {
				log.Error(err)
			}
			j.Terms = subQuery(termRows, "academicSessions")

			classes = append(classes, j)
		}
	}
	return classes
}
