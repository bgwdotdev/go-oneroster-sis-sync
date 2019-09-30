/** users - pupils **/
-- name: select-users-pupil
SELECT
    P.NAME_ID AS sourcedId,
    case when P.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* P.LAST_AMEND_DATE as dateLastModified, */
    N.EMAIL_ADDRESS AS username,
    '' AS userIds, -- GUIDRef[0..*]
    /* change to PASS API allow? */
    case when P.IN_USE = 'Y' then 'true' else 'false' end AS enabledUser,
    N.PREFERRED_NAME AS givenName,
    N.SURNAME AS familyName,
    '' AS middlename,
    'student' AS role,
    P.CODE AS identifier,
    N.EMAIL_ADDRESS AS email,
    '' AS sms,
    '' AS phone,
    '' AS agentSourcedIds, -- GUIDRef[0..*]
    school.SCHOOL_ID AS orgSourcedIds, --GUIDRef[1..*]
    formYear.AGE_RANGE AS grades,
    '' AS password
FROM
    dbo.PUPIL AS P
        INNER JOIN
    dbo.NAME AS N
        ON P.NAME_ID = N.NAME_ID
        INNER JOIN
    dbo.FORM AS form
        ON P.FORM = form.CODE
        INNER JOIN
    dbo.FORM_YEAR AS formYear
        ON form.YEAR_CODE = formYear.CODE
    inner join dbo.SCHOOL
        on p.school = school.code
WHERE 
    P.ACADEMIC_YEAR = @p1
    AND
    form.ACADEMIC_YEAR = @p1
ORDER BY
    sourcedId

/** users - staff **/
-- name: select-users-staff
SELECT 
    U.NAME_ID AS sourcedId,
    case when U.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* U.LAST_AMEND_DATE AS dateLastModified, */
    U.INTERNAL_EMAIL_ADDRESS AS username,
    '' AS userIds, -- GUIDRef[0..*]
    case when U.IN_USE = 'Y' then 'true' else 'false' end AS enabledUser,
    N.PREFERRED_NAME AS givenName,
    N.SURNAME AS familyname,
    '' AS middlename,
    'teacher' AS role,
    U.CODE AS identifier,
    U.INTERNAL_EMAIL_ADDRESS AS email,
    '' AS sms,
    '' AS phone,
    U.NAME_ID AS agentSourcedIds, -- GUIDRef[0..*]
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
ORDER BY
    sourcedId

/** users - support staff **/
-- name: select-user-support-staff
SELECT 
    U.NAME_ID AS sourcedId,
    case when U.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* U.LAST_AMEND_DATE AS dateLastModified, */
    U.INTERNAL_EMAIL_ADDRESS AS username,
    '' AS userIds, -- GUIDRef[0..*]
    case when U.IN_USE = 'Y' then 'true' else 'false' end AS enabledUser,
    N.PREFERRED_NAME AS givenName,
    N.SURNAME AS familyname,
    '' AS middlename,
    'aide' AS role,
    U.CODE AS identifier,
    U.INTERNAL_EMAIL_ADDRESS AS email,
    '' AS sms,
    '' AS phone,
    U.NAME_ID AS agentSourcedIds, -- GUIDRef[0..*]
    school.school_id AS orgSourcedIds, -- GUIDRef[1..*]
    '' AS grades,
    '' AS password
FROM
    dbo.STAFF as U
        INNER JOIN
    dbo.NAME AS N
        ON N.NAME_ID = U.NAME_ID
WHERE
    U.CATEGORY = 'NON001'
    OR
    U.CATEGORY = 'COACH'
ORDER BY
    sourcedId
