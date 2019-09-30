/** enrollments - scheduled - pupils **/
-- name: select-enrollments-scheduled--pupil
SELECT
    P.PUPIL_SET_ID AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* null AS dateLastModified, */
    PUPIL.NAME_ID AS userSourcedId,
    P.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID AS schoolSourcedId,
    'student' AS role,
    '' AS primary,
    '' AS beginDate,
    '' AS endDate
FROM
    dbo.PUPIL_SET AS P
        INNER JOIN
    dbo.SUBJECT_SET AS SS
        ON SS.SUBJECT_SET_ID = P.SUBJECT_SET_ID
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = SS.SCHOOL
        INNER JOIN
    dbo.PUPIL
        ON PUPIL.PUPIL_ID = P.PUPIL_ID
WHERE
    SS.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId
/** enrollments - homeroom - pupils **/
-- name: select-enrollments-homeroom-pupil
SELECT
    CONCAT(FORM.FORM_ID, PUPIL.PUPIL_ID) AS sourcedId
    , case when FORM.IN_USE = 'Y' then 'active' else 'inactive' end AS status
    /* ,null AS dateLastModified */
    ,FORM.FORM_ID AS classSourcedId
    ,SCHOOL.SCHOOL_ID AS schoolSourcedId
    ,PUPIL.NAME_ID AS userSourcedId
    ,'student' AS role
    ,'' AS primary
    ,'' AS beginDate 
    ,'' AS endDate
FROM
    dbo.PUPIL
        INNER JOIN
    dbo.FORM
        ON FORM.CODE = PUPIL.FORM
        INNER JOIN
    dbo.SCHOOL
        ON SCHOOL.CODE = PUPIL.SCHOOL 
WHERE
    FORM.ACADEMIC_YEAR = @p1 
    AND PUPIL.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId

/** enrollments - homeroom - teacher **/
-- name: select-enrollments-homeroom-teacher
DECLARE @T bit
SET @T=1
SELECT
   CONCAT(FORM.FORM_ID, STAFF.NAME_ID) AS sourcedId
    , case when FORM.IN_USE = 'Y' then 'active' else 'inactive' end AS status
    /* ,null AS dateLastModified */
    ,FORM.FORM_ID As classSourcedId
    ,SCHOOL.SCHOOL_ID AS schoolSourcedId
    ,STAFF.NAME_ID AS userSourcedId
    ,'teacher' AS role
    ,@T AS 'primary'    
    ,'' AS beginDate
    ,'' AS endDate
FROM
    dbo.FORM
        INNER JOIN
    dbo.STAFF
        ON FORM.TUTOR = STAFF.CODE
        INNER JOIN
    dbo.SCHOOL
        ON SCHOOL.CODE = STAFF.SCHOOL 
WHERE
    FORM.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId

/** enrollments - Teacher 1 **/
-- name: select-enrollments-scheduled-teacher-1
SELECT
    CONCAT(SS.SUBJECT_SET_ID, S.NAME_ID) AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* null AS dateLastModified */
    SS.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID as schoolSourcedId,
    S.NAME_ID AS userSourcedId,
    'teacher' AS role,
    @T AS 'primary',
    '' AS begindate,
    '' AS endDate
FROM
    dbo.SUBJECT_SET AS SS
        INNER JOIN
    dbo.STAFF AS S
        ON SS.TUTOR = S.CODE
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = SS.SCHOOL
WHERE
    SS.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId
    
/** enrollments - Teacher 2 **/
-- name: select-enrollments-scheduled-teacher-2
DECLARE @F bit
SET @F=0
SELECT
    CONCAT(SS.SUBJECT_SET_ID, S.NAME_ID) AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* null AS dateLastModified */
    SS.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID as schoolSourcedId,
    S.NAME_ID AS userSourcedId,
    'teacher' AS role,
    @F AS 'primary',
    '' AS begindate,
    '' AS endDate
FROM
    dbo.SUBJECT_SET AS SS
        INNER JOIN
    dbo.STAFF AS S
        ON SS.TUTOR_2 = S.CODE
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = SS.SCHOOL
WHERE
    SS.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId

/** enrollments - Teacher 3 **/
-- name: select-enrollment-scheduled-teacher-3
SELECT
    CONCAT(SS.SUBJECT_SET_ID, S.NAME_ID) AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* null AS dateLastModified */
    SS.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID as schoolSourcedId,
    S.NAME_ID AS userSourcedId,
    'teacher' AS role,
    @F AS 'primary',
    '' AS begindate,
    '' AS endDate
FROM
    dbo.SUBJECT_SET AS SS
        INNER JOIN
    dbo.STAFF AS S
        ON SS.TUTOR_3 = S.CODE
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = SS.SCHOOL
WHERE
    SS.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId
