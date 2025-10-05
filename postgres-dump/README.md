```
psql -U  postgrs # 암호 입력

CREATE USER ils_admin WITH PASSWORD 'wldn0901';
CREATE USER lms_admin WITH PASSWORD 'wldn0901';

ALTER ROLE ils_admin SUPERUSER;
ALTER ROLE lms_admin SUPERUSER;

CREATE DATABASE ils;
CREATE DATABASE lms;

ALTER DATABASE ils OWNER TO ils_admin;
ALTER DATABASE lms OWNER TO lms_admin;

psql -U ils_admin -d ils < ils_backup_new.sql
psql -U lms_admin -d lms < lms_backup_new.sql
```
