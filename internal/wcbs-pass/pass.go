package pass

import (
	"database/sql"
	_ "github.com/denisenkom/go-mssqldb"
	"github.com/fffnite/go-oneroster-sis-sync/internal/sync"
	or "github.com/fffnite/go-oneroster/ormodel"
	"github.com/gchaincl/dotsql"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
	"time"
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

func RunBuild(db *sql.DB, dot *dotsql.DotSql, token string) {
	classes := BuildClasses(db, dot)
	for _, v := range classes {
		sync.PutData(v, "/classes/"+v.SourcedId, token)
	}
	as := BuildAcademicSessions(db, dot)
	for _, v := range as {
		sync.PutData(v, "/academicSessions/"+v.SourcedId, token)
	}
	courses := BuildCourses(db, dot)
	for _, v := range courses {
		sync.PutData(v, "/courses/"+v.SourcedId, token)
	}
	enrollments := BuildEnrollments(db, dot)
	for _, v := range enrollments {
		sync.PutData(v, "/enrollments/"+v.SourcedId, token)
	}
	orgs := BuildOrgs(db, dot)
	for _, v := range orgs {
		sync.PutData(v, "/orgs/"+v.SourcedId, token)
	}
	users := BuildUsers(db, dot)
	for _, v := range users {
		sync.PutData(v, "/users/"+v.SourcedId, token)
	}
}

func BuildUsers(db *sql.DB, dot *dotsql.DotSql) []or.Users {
	var users []or.Users
	queries := []string{
		"select-users-pupil",
		"select-users-staff",
		"select-users-staff-support",
	}
	for _, q := range queries {
		log.Infof("starting: %s", q)
		lm := viper.Get("sis_last_modified")
		ay := viper.Get("sis_academic_year")
		rows, err := dot.Query(db, q, lm, ay)
		if err != nil {
			log.Error(err)
		}
		for rows.Next() {
			var o or.Users
			var userIds or.NestedUid
			var agents or.Nested
			var orgs or.Nested
			var grades string
			err := rows.Scan(
				&o.SourcedId,
				&o.Status,
				&o.Username,
				&userIds.Identifier,
				&o.EnabledUser,
				&o.GivenName,
				&o.FamilyName,
				&o.MiddleName,
				&o.Role,
				&o.Identifier,
				&o.Email,
				&o.SMS,
				&o.Phone,
				&agents.SourcedId,
				&orgs.SourcedId,
				&grades,
				&o.Password,
			)
			if err != nil {
				log.Error(err)
				continue
			}
			o.DateLastModified = time.Now()
			if userIds.Identifier != "" {
				userIds.Type = "placeholder"
				o.UserIds = append(o.UserIds, &userIds)
			}
			if agents.SourcedId != "" {
				agents.Type = "user"
				o.Agents = append(o.Agents, &agents)
			}
			if orgs.SourcedId != "" {
				orgs.Type = "orgs"
				o.Orgs = append(o.Orgs, &orgs)
			}
			if grades != "" {
				o.Grades = append(o.Grades, grades)
			}

			users = append(users, o)
		}
	}
	return users
}

func BuildOrgs(db *sql.DB, dot *dotsql.DotSql) []or.Orgs {
	var orgs []or.Orgs
	queries := []string{"select-orgs"}
	for _, q := range queries {
		log.Infof("starting: %s", q)
		lm := viper.Get("sis_last_modified")
		rows, err := dot.Query(db, q, lm)
		if err != nil {
			log.Error(err)
		}
		for rows.Next() {
			var o or.Orgs
			var parent or.Nested
			var children or.Nested
			err := rows.Scan(
				&o.SourcedId,
				&o.Status,
				&o.Name,
				&o.Type,
				&o.Identifier,
				&parent.SourcedId,
				&children.SourcedId,
			)
			if err != nil {
				log.Error(err)
				continue
			}
			o.DateLastModified = time.Now()
			if parent.SourcedId != "" {
				parent.Type = "org"
				o.Parent = &parent
			}
			if children.SourcedId != "" {
				children.Type = "org"
				o.Children = append(o.Children, &children)
			}

			orgs = append(orgs, o)
		}
	}
	return orgs
}

func BuildEnrollments(db *sql.DB, dot *dotsql.DotSql) []or.Enrollments {
	var enrollments []or.Enrollments
	queries := []string{
		"select-enrollments-scheduled-pupil",
		"select-enrollments-homeroom-pupil",
		"select-enrollments-homeroom-teacher",
		"select-enrollments-scheduled-teacher-1",
		"select-enrollments-scheduled-teacher-2",
		"select-enrollments-scheduled-teacher-3",
	}
	for _, q := range queries {
		log.Infof("starting: %s", q)
		rows, err := dot.Query(db, q, viper.Get("sis_academic_year"))
		if err != nil {
			log.Error(err)
		}
		for rows.Next() {
			var o or.Enrollments
			var user or.Nested
			var class or.Nested
			var school or.Nested
			err = rows.Scan(
				&o.SourcedId,
				&o.Status,
				&user.SourcedId,
				&class.SourcedId,
				&school.SourcedId,
				&o.Role,
				&o.Primary,
				&o.BeginDate,
				&o.EndDate,
			)
			if err != nil {
				log.Error(err)
				continue
			}
			o.DateLastModified = time.Now()
			user.Type = "user"
			o.User = &user
			class.Type = "class"
			o.Class = &class
			school.Type = "org"
			o.School = &school

			enrollments = append(enrollments, o)
		}
	}
	return enrollments
}

func BuildCourses(db *sql.DB, dot *dotsql.DotSql) []or.Courses {
	var courses []or.Courses
	queries := []string{"select-courses"}
	for _, q := range queries {
		log.Infof("starting: %s", q)
		lm := viper.Get("sis_last_modified")
		ay := viper.Get("sis_academic_year")
		rows, err := dot.Query(db, q, lm, ay)
		if err != nil {
			log.Error(err)
		}
		for rows.Next() {
			var o or.Courses
			var schoolYear or.Nested
			var grades string
			var subjects string
			var org or.Nested
			var subjectCodes string
			err = rows.Scan(
				&o.SourcedId,
				&o.Status,
				&o.Title,
				&schoolYear.SourcedId,
				&o.CourseCode,
				&grades,
				&subjects,
				&org.SourcedId,
				&subjectCodes,
			)
			if err != nil {
				log.Error(err)
				continue
			}
			o.DateLastModified = time.Now()
			if schoolYear.SourcedId != "" {
				schoolYear.Type = "academicSession"
				o.SchoolYear = &schoolYear
			}
			if grades != "" {
				o.Grades = append(o.Grades, grades)
			}
			if subjects != "" {
				o.Subjects = append(o.Subjects, subjects)
			}
			org.Type = "org"
			o.Org = &org
			if subjectCodes != "" {
				o.SubjectCodes = append(o.SubjectCodes, subjectCodes)
			}

			courses = append(courses, o)
		}
	}
	return courses
}

func BuildAcademicSessions(db *sql.DB, dot *dotsql.DotSql) []or.AcademicSessions {
	var academicSessions []or.AcademicSessions
	queries := []string{"select-academicSession-years"}
	for _, q := range queries {
		log.Infof("starting: %s", q)
		lm := viper.Get("sis_last_modified")
		ay := viper.Get("sis_academic_year")
		rows, err := dot.Query(db, q, lm, ay)
		if err != nil {
			log.Error(err)
		}
		for rows.Next() {
			var o or.AcademicSessions
			err = rows.Scan(
				&o.SourcedId,
				&o.Status,
				&o.Title,
				&o.StartDate,
				&o.EndDate,
				&o.SchoolYear,
			)
			if err != nil {
				log.Error(err)
				continue
			}
			o.DateLastModified = time.Now()
			academicSessions = append(academicSessions, o)
		}
	}
	return academicSessions
}

func BuildClasses(db *sql.DB, dot *dotsql.DotSql) []or.Classes {
	var classes []or.Classes
	c := []string{"select-classes-scheduled", "select-classes-homeroom"}
	for _, v := range c {
		log.Infof("starting: %s", v)
		lm := viper.Get("sis_last_modified")
		ay := viper.Get("sis_academic_year")
		rows, err := dot.Query(db, v, lm, ay)
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
				continue
			}
			j.DateLastModified = time.Now()
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
