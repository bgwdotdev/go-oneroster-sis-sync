-- name: select-academicSession-years
SELECT
    Y.YEAR_ID AS sourcedId,
    case when Y.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* Y.LAST_AMEND_DATE AS dateLastModified, */
    Y.DESCRIPTION AS title,
    SC.YEAR_START AS startDate,
    SC.YEAR_END AS endDate,
    'schoolYear' AS 'type',
    Y.CODE AS schoolYear
FROM 
    dbo.YEAR AS Y INNER JOIN
    dbo.SCHOOL_CALENDAR AS SC ON SC.ACADEMIC_YEAR = Y.CODE
WHERE Y.LAST_AMEND_DATE > @p1
AND Y.CODE = @p2
ORDER BY 
    sourcedId

-- name: select-classes-scheduled
SELECT
    S.SUBJECT_SET_ID AS sourcedId,
    case when S.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* S.LAST_AMEND_DATE AS dateLastModified, */
    S.DESCRIPTION AS title,
    '' AS grades,
    SUB.SUBJECT_ID AS course,
    S.SET_CODE AS classCode,
    'scheduled' AS classType,
    /* S.ROOM AS location, */
    '' AS location,
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
WHERE S.LAST_AMEND_DATE > @p1
AND S.academic_year = @p2
ORDER BY
    sourcedId
-- name: select-classes-scheduled-terms
select year.year_id 
from dbo.year 
inner join dbo.subject_set 
    on subject_set.academic_year = year.code 
where subject_set.academic_year = @p1
and subject_set.subject_set_id = @p2 

-- name: select-classes-homeroom
SELECT
    F.FORM_ID AS sourcedId,
    case when F.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* F.LAST_AMEND_DATE AS dateLastModified, */
    F.DESCRIPTION AS title,
    FORM_YEAR.AGE_RANGE AS grades,
    '40705669' AS course, /* CHANGE FOR YOUR IMPORT */
    F.CODE AS classCode,
    'homeroom' AS classType,
    case when F.ROOM is null then '' else F.ROOM end AS location,
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
WHERE F.LAST_AMEND_DATE > @p1
AND F.ACADEMIC_YEAR = @p2
ORDER BY
    sourcedId
-- name: select-classes-homeroom-terms
select year.year_id
from dbo.year
inner join dbo.form
    on form.academic_year = year.code
where form.academic_year = @p1
and form.form_id = @p2

-- name: select-courses
SELECT
    S.SUBJECT_ID AS sourcedId,
    case when S.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* S.LAST_AMEND_DATE AS dateLastModified, */
    S.DESCRIPTION AS title,
    '' AS schoolYear, -- GUIDRef[0..1]
    S.CODE AS courseCode,
    '' AS grades, -- string[0..*]
    S.DESCRIPTION AS subjects,
    org.SCHOOL_ID AS org, -- GUIDRef[1]
    '' AS subjectCodes
FROM
    dbo.SUBJECT AS S 
        INNER JOIN
    dbo.SCHOOL AS org
        ON org.CODE = S.SCHOOL
WHERE S.LAST_AMEND_DATE > @p1
ORDER BY
    sourcedId

-- name: select-enrollments-scheduled-pupil
SELECT
    P.PUPIL_SET_ID AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* null AS dateLastModified, */
    PUPIL.NAME_ID AS userSourcedId,
    P.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID AS schoolSourcedId,
    'student' AS role,
    0 AS 'primary',
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
WHERE SS.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId
-- name: select-enrollments-homeroom-pupil
SELECT
    CONCAT(FORM.FORM_ID, PUPIL.PUPIL_ID) AS sourcedId
    , case when FORM.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status
    /* ,null AS dateLastModified */
    ,PUPIL.NAME_ID AS userSourcedId
    ,FORM.FORM_ID AS classSourcedId
    ,SCHOOL.SCHOOL_ID AS schoolSourcedId
    ,'student' AS role
    ,0 AS 'primary'
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

-- name: select-enrollments-homeroom-teacher
DECLARE @T bit
SET @T=1
SELECT
   CONCAT(FORM.FORM_ID, STAFF.NAME_ID) AS sourcedId
    , case when FORM.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status
    /* ,null AS dateLastModified */
    ,STAFF.NAME_ID AS userSourcedId
    ,FORM.FORM_ID As classSourcedId
    ,SCHOOL.SCHOOL_ID AS schoolSourcedId
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

-- name: select-enrollments-scheduled-teacher-1
DECLARE @T bit
SET @T=1
SELECT
    CONCAT(SS.SUBJECT_SET_ID, S.NAME_ID) AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* null AS dateLastModified */
    S.NAME_ID AS userSourcedId,
    SS.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID as schoolSourcedId,
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
    
-- name: select-enrollments-scheduled-teacher-2
DECLARE @F bit
SET @F=0
SELECT
    CONCAT(SS.SUBJECT_SET_ID, S.NAME_ID) AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* null AS dateLastModified */
    S.NAME_ID AS userSourcedId,
    SS.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID as schoolSourcedId,
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

-- name: select-enrollments-scheduled-teacher-3
SELECT
    CONCAT(SS.SUBJECT_SET_ID, S.NAME_ID) AS sourcedId,
    case when SS.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* null AS dateLastModified */
    S.NAME_ID AS userSourcedId,
    SS.SUBJECT_SET_ID AS classSourcedId,
    org.SCHOOL_ID as schoolSourcedId,
    'teacher' AS role,
    0 AS 'primary',
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

-- name: select-orgs
SELECT
    SCHOOL_ID AS sourcedId,
    case when IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* null AS dateLastModified */
    CODE as name,
    'school' AS 'type',
    DESCRIPTION AS identifier,
    '' AS parent, -- GUIRef[0..1]
    '' AS children -- GUIDRef[0..*]
FROM 
    dbo.SCHOOL
WHERE LAST_AMEND_DATE > @p1
ORDER BY
    sourcedId 

-- name: select-users-pupil
SELECT P.NAME_ID AS 'user.sourcedId'
    , CASE 
        WHEN P.IN_USE = 'Y'
            THEN 'active'
        ELSE 'tobedeleted'
        END AS 'user.status'
    ,
    /* P.LAST_AMEND_DATE as dateLastModified, */
    CASE 
        WHEN N.EMAIL_ADDRESS IS NULL
            THEN 'NULL'
        ELSE N.EMAIL_ADDRESS
        END AS 'user.username'
    , (
        SELECT '' AS 'type'
            , '' AS 'identifier'
        FOR json path
        ) AS 'user.userIds'
    , CASE 
        WHEN P.IN_USE = 'Y'
            THEN CAST(1 as bit)
        ELSE CAST(0 as bit)
        END AS 'user.enabledUser'
    , N.PREFERRED_NAME AS 'user.givenName' -- change to PASS API 'allow' ?
    , N.SURNAME AS 'user.familyName'
    , '' AS 'user.middlename'
    , 'student' AS 'user.role'
    , P.CODE AS 'user.identifier'
    , CASE 
        WHEN N.EMAIL_ADDRESS IS NULL
            THEN 'NULL'
        ELSE N.EMAIL_ADDRESS
        END AS 'user.email'
    , '' AS 'user.sms'
    , '' AS 'user.phone'
    , (
        SELECT r.to_name_id AS 'sourcedId'
            , 'user' AS 'type'
        FROM dbo.relationship AS r
        WHERE p.name_id = r.from_name_id
            AND r.rank <= '2'
        FOR json path
        ) AS 'user.agents'
    , (
        SELECT s.SCHOOL_ID AS 'sourcedId'
            , 'org' AS 'type'
        FROM dbo.school AS s
        WHERE p.school = s.CODE
        FOR json PATH
        ) AS 'user.orgs'
    , JSON_QUERY(CONCAT (
            '["'
            , formYear.AGE_RANGE
            /* -- TEMPLATE FOR ARRAY VALUES
            , '","'
            , formyear.AGE_RANGE_2
            */
            , '"]'
            )) AS 'user.grades'
    , '' AS 'user.password'
FROM dbo.PUPIL AS P
INNER JOIN dbo.NAME AS N
    ON P.NAME_ID = N.NAME_ID
INNER JOIN dbo.FORM AS form
    ON P.FORM = form.CODE
INNER JOIN dbo.FORM_YEAR AS formYear
    ON form.YEAR_CODE = formYear.CODE
WHERE P.LAST_AMEND_DATE > @p1
    AND P.ACADEMIC_YEAR = @p2
    AND form.ACADEMIC_YEAR = @p2
    AND P.RECORD_TYPE = 1
ORDER BY 'user.sourcedId'
FOR JSON PATH
    --, ROOT('users')

-- name: select-users-staff
SELECT 
    U.NAME_ID AS sourcedId,
    case when U.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* U.LAST_AMEND_DATE AS dateLastModified, */
    case when U.INTERNAL_EMAIL_ADDRESS is null then 'NULL' else U.INTERNAL_EMAIL_ADDRESS end AS username,
    '' AS userIds, -- GUIDRef[0..*]
    case when U.IN_USE = 'Y' then 'true' else 'false' end AS enabledUser,
    N.PREFERRED_NAME AS givenName,
    N.SURNAME AS familyname,
    '' AS middlename,
    'teacher' AS role,
    U.CODE AS identifier,
    case when U.INTERNAL_EMAIL_ADDRESS is null then 'NULL' else U.INTERNAL_EMAIL_ADDRESS end AS email,
    '' AS sms,
    '' AS phone,
    '' AS agentSourcedIds, -- GUIDRef[0..*]
    school.school_id AS orgSourcedIds, -- GUIDRef[1..*]
    '' AS grades,
    '' AS password
FROM
    dbo.STAFF as U
        INNER JOIN
    dbo.NAME AS N
        ON N.NAME_ID = U.NAME_ID
    inner join dbo.school
    on school.code = U.school
WHERE
    U.CATEGORY = 'TEA001'
    OR
    U.CATEGORY = 'SUPPLY'
    OR
    U.CATEGORY = 'EARLY'
AND U.LAST_AMEND_DATE > @p1
ORDER BY
    sourcedId

-- name: select-users-staff-support
SELECT 
    U.NAME_ID AS sourcedId,
    case when U.IN_USE = 'Y' then 'active' else 'tobedeleted' end AS status,
    /* U.LAST_AMEND_DATE AS dateLastModified, */
    case when U.INTERNAL_EMAIL_ADDRESS is null then 'NULL' else U.INTERNAL_EMAIL_ADDRESS end AS username,
    '' AS userIds, -- GUIDRef[0..*]
    case when U.IN_USE = 'Y' then 'true' else 'false' end AS enabledUser,
    N.PREFERRED_NAME AS givenName,
    N.SURNAME AS familyname,
    '' AS middlename,
    'aide' AS role,
    U.CODE AS identifier,
    case when U.INTERNAL_EMAIL_ADDRESS is null then 'NULL' else U.INTERNAL_EMAIL_ADDRESS end AS email,
    '' AS sms,
    '' AS phone,
    '' AS agentSourcedIds, -- GUIDRef[0..*]
    school.school_id AS orgSourcedIds, -- GUIDRef[1..*]
    '' AS grades,
    '' AS password
FROM
    dbo.STAFF as U
        INNER JOIN
    dbo.NAME AS N
        ON N.NAME_ID = U.NAME_ID
    inner join dbo.school
    on school.code = U.school
WHERE
    U.CATEGORY = 'NON001'
    OR
    U.CATEGORY = 'COACH'
AND U.LAST_AMEND_DATE > @p1
ORDER BY
    sourcedId

-- name: select-users-parents
SELECT n.name_id AS 'user.sourcedId'
    , n.EMAIL_ADDRESS AS 'user.username'
    -- userids
    , CASE 
        WHEN n.CONTACT_IN_USE = 'Y'
            THEN CAST(1 as bit)
        ELSE CAST(0 as bit)
        END AS 'user.enabledUser'
    , n.PREFERRED_NAME AS 'user.givenName'
    , n.SURNAME AS 'user.familyName'
    , '' AS 'user.middleName'
    , CASE 
        WHEN EXISTS (
                SELECT 1
                FROM dbo.name
                JOIN dbo.relationship
                    ON n.name_id = relationship.TO_NAME_ID
                JOIN dbo.RELATIONSHIP_TYPE AS rety
                    ON relationship.RELATION_ID = rety.ID
                WHERE rety.TO_RELATION = 'mother'
                    OR rety.TO_RELATION = 'father'
                )
            THEN 'parent'
        WHEN EXISTS (
                SELECT 1
                FROM dbo.name
                JOIN dbo.relationship
                    ON n.name_id = relationship.TO_NAME_ID
                JOIN dbo.RELATIONSHIP_TYPE AS rety
                    ON relationship.RELATION_ID = rety.ID
                WHERE rety.TO_RELATION = 'guardian'
                )
            THEN 'guardian'
        ELSE 'relative'
        END AS 'user.role'
    , n.NAME_CODE AS 'user.identifier'
    , n.EMAIL_ADDRESS AS 'user.email'
    , '' AS 'user.sms'
    , '' AS 'user.phone'
    , (
        SELECT rel.FROM_NAME_ID AS 'sourcedId'
            , 'user' AS 'type'
          --  , pupil.ACADEMIC_YEAR 'academic year'
        FROM dbo.RELATIONSHIP AS rel
        JOIN dbo.pupil
            ON rel.FROM_NAME_ID = pupil.NAME_ID
        WHERE rel.TO_NAME_ID = n.name_id
            AND pupil.ACADEMIC_YEAR = @p2
        FOR json path
        ) AS 'user.agents'
    , (
        SELECT s.school_id AS 'sourcedId'
            , 'org' AS 'type'
        FROM dbo.relationship AS rel
        JOIN dbo.pupil AS pu
            ON rel.FROM_NAME_ID = pu.NAME_ID
        JOIN dbo.school AS s
            ON pu.school = s.code
        WHERE rel.TO_NAME_ID = n.NAME_ID
        GROUP BY s.SCHOOL_ID
        FOR json PATH
        ) AS 'user.orgs'
    -- grades
    , '' AS 'user.password'
FROM dbo.name AS n
-- validate user is a primary contact and not pupil
-- no 'role' flag or column for validating parent/guardian status within pass
WHERE EXISTS (
        SELECT 1
        FROM dbo.name na
        JOIN dbo.RELATIONSHIP re
            ON na.name_id = re.to_name_id
        JOIN dbo.RELATIONSHIP_TYPE rety
            ON re.RELATION_ID = rety.ID
        JOIN dbo.pupil pu
            ON pu.NAME_ID = re.FROM_NAME_ID
        WHERE n.name_id = re.to_name_id
            AND re.rank <= 2
            AND rety.TO_RELATION != 'pupil'
            AND pu.LAST_AMEND_DATE > @p1
            AND pu.ACADEMIC_YEAR = @p2
        )
ORDER BY n.name_id
FOR json path
