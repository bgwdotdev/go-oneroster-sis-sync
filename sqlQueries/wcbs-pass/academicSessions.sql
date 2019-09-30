/** academicSession - academic Years **/
-- name: select-academicSession-years
SELECT
    Y.YEAR_ID AS sourcedId,
    case when Y.IN_USE = 'Y' then 'active' else 'inactive' end AS status,
    /* Y.LAST_AMEND_DATE AS dateLastModified, */
    Y.DESCRIPTION AS title,
    SC.YEAR_START AS startDate,
    SC.YEAR_END AS endDate,
    Y.CODE AS schoolYear
FROM 
    dbo.YEAR AS Y INNER JOIN
    dbo.SCHOOL_CALENDAR AS SC ON SC.ACADEMIC_YEAR = Y.CODE
ORDER BY 
    sourcedId
/** academicSession - terms **/


