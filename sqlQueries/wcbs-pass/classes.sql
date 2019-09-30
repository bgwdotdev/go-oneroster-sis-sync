/** classes - scheduled **/ 
-- name: select-classes-scheduled-test
select top (1)
    SUBJECT_SET_ID AS sourcedId
    from
    dbo.Subject_set
    where
    academic_year = @p1
    order by
    sourcedId
-- name: select-classes-scheduled
SELECT
    S.SUBJECT_SET_ID AS sourcedId,
    S.IN_USE AS status,
    S.LAST_AMEND_DATE AS dateLastModified,
    S.DESCRIPTION AS title,
    /* null AS grades, */
    SUB.SUBJECT_ID AS courseSourcedId,
    S.SET_CODE AS classCode,
    'scheduled' AS classType,
    S.ROOM AS location,
    org.SCHOOL_ID AS school,
    /* S.SUBJECT_SET_ID AS terms, */ 
    SUB.DESCRIPTION AS subjects
    /* SQA CODES? AS subjectCodes, */
    /* null AS periods */ 
FROM
    dbo.SUBJECT_SET AS S
        INNER JOIN
    dbo.SCHOOL as org
        on org.CODE = S.SCHOOL
        INNER JOIN
    dbo.YEAR as Y
        on Y.CODE = S.ACADEMIC_YEAR
        INNER JOIN
    dbo.SUBJECT AS SUB
        ON SUB.CODE = S.SUBJECT
WHERE academic_year = @p1
ORDER BY
    sourcedId
-- name: select-classes-scheduled-terms
select year.year_id 
from dbo.year 
inner join dbo.subject_set 
    on subject_set.academic_year = year.code 
where subject_set.subject_set_id = @p2 
and subject_set.academic_year = @p1
/** classes - homeroom(form) **/
-- name: select-classes-homeroom
SELECT
    F.FORM_ID AS sourcedId,
    F.IN_USE AS status,
    F.LAST_AMEND_DATE AS dateLastModified,
    F.DESCRIPTION AS title,
    FORM_YEAR.AGE_RANGE AS grades,
    /* null AS courseSourcedId */
    F.CODE AS classCode,
    'homeroom' AS classType,
    F.ROOM AS location,
    org.SCHOOL_ID AS schoolSourcedId,
    F.FORM_ID AS termSourcedIds
    /* null AS subjects */
    /* null AS subjectCodes */
    /* null as periods */
FROM
    dbo.FORM AS F
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = F.SCHOOL
        INNER JOIN
    dbo.FORM_YEAR
        ON FORM_YEAR.CODE = F.YEAR_CODE
ORDER BY
    sourcedId


