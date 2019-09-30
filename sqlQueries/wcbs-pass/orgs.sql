/** Orgs **/
-- name: select-orgs
SELECT
    SCHOOL_ID AS sourcedId,
    case when IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* null AS dateLastModified */
    CODE as name,
    'school' AS type,
    DESCRIPTION AS identifier,
    IN_USE AS status,
    '' AS parent, -- GUIRef[0..1]
    '' AS children -- GUIDRef[0..*]
FROM 
    dbo.SCHOOL
ORDER BY
    sourcedId 
