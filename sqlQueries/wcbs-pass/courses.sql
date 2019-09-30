/** courses **/
-- name: select-courses
SELECT
    S.SUBJECT_ID AS sourcedId,
    S.IN_USE AS status,
    /* S.LAST_AMEND_DATE AS dateLastModified, */
    S.DESCRIPTION AS title,
    '' AS schoolYear, -- GUIDRef[0..1]
    S.CODE AS courseCode,
    '' AS grades,
    S.DESCRIPTION AS subjects,
    org.SCHOOL_ID AS org,
    '' AS subjectCodes
FROM
    dbo.SUBJECT AS S 
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = S.SCHOOL
ORDER BY
    sourcedId

/*
-- name: select-courses-academicYear
*/
