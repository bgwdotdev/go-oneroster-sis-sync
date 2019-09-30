/** classes - scheduled **/ 
-- name: select-classes-scheduled
SELECT
    S.SUBJECT_SET_ID AS sourcedId,
    case when S.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* S.LAST_AMEND_DATE AS dateLastModified, */
    S.DESCRIPTION AS title,
    '' AS grades,
    SUB.SUBJECT_ID AS course,
    S.SET_CODE AS classCode,
    'scheduled' AS classType,
    S.ROOM AS location,
    org.SCHOOL_ID AS school,
    /* NEST dbo.year AS terms, */ 
    SUB.DESCRIPTION AS subjects,
    '' AS subjectCodes, 
    '' AS periods  
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
where subject_set.academic_year = @p1
and subject_set.subject_set_id = @p2 

/** classes - homeroom(form) **/
-- name: select-classes-homeroom
SELECT
    F.FORM_ID AS sourcedId,
    case when F.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* F.LAST_AMEND_DATE AS dateLastModified, */
    F.DESCRIPTION AS title,
    FORM_YEAR.AGE_RANGE AS grades,
    '<PLACEHOLDER>' AS course,
    F.CODE AS classCode,
    'homeroom' AS classType,
    F.ROOM AS location,
    org.SCHOOL_ID AS school,
    /* NEST dbo.year AS term, */
    '' AS subjects,
    '' AS subjectCodes,
    '' as periods 
FROM
    dbo.FORM AS F
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = F.SCHOOL
        INNER JOIN
    dbo.FORM_YEAR
        ON FORM_YEAR.CODE = F.YEAR_CODE
WHERE
    F.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId
-- name: select-classes-homeroom-terms
select year.year_id
from dbo.year
inner join dbo.form
    on form.academic_year = year.code
where form.academic_year = @p1
and form.form_id = @p2
