# GOORS SIS Sync

Go Oneroster SIS Sync provides sql queries and accompanying app to
pull data from an SIS database and uploads to a go oneroster api

## Supports

* WCBS PASS

## Setup

The application connects to your MSSQL database, scraps and formats
the data and then uploads it to a 
[go oneroster api server](https://github.com/fffnite/go-oneroster)

Use either the command flags or the env vars and run app as
frequently as required

#### flags

flag help is available with `goors-sync -h`

```
goors-sync \
    -U $clientId \
    -P $clientSecret \
    -u "https://goors.mydomain.com/ims/oneroster/v1p1" \
    -y $currentAcademicYear \
    -m $lastModifiedAfter \
    -p "./path/to/queries.sql" \
    -s "sqlserver://username:password@host:port?database=MySIS&connection+timeout=30"
```

### envs

All envs should be prefixed with `GOORS`  
Example Bash:`export GOORS_ENV='value'`  
Example Powershell: `$ENV:GOORS_ENV="value"`  

``` 
GOORS_API_CI='username'
GOORS_API_CS='password'
GOORS_API_URL='https://goors.mydomain.com/ims/oneroster/v1p1'
GOORS_SIS_ACADEMIC_YEAR='2019'
GOORS_SIS_LAST_MODIFIED='2019-01-01'
GOORS_SQL_FILE_PATH='./path/to/queries.sql'
GOORS_SQLCONNSTRING='sqlserver://username:password@host:port?database=MySIS&connection+timeout=30'
```

### WCBS PASS Conf

The wcbs-pass.sql file may have to modified to change the
'U.CATEGORY' (STAFF.CATEGORY) to match your SIS config of 
teaching vs. non-teaching staff until PASS provides
standardised support.
