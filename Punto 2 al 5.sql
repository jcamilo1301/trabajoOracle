
------------- 2
-- a)  first one with 2 Gb and 1 datafile, tablespace should be named uber?
CREATE TABLESPACE  uber
DATAFILE 'uber.dbf' SIZE 2G;

-- b) Undo tablespace with 25Mb of space and 1 datafile
CREATE UNDO TABLESPACE  undouber
DATAFILE 'undouber.dbf' SIZE 25M;

-- c) Bigfile tablespace of 5Gb
CREATE BIGFILE TABLESPACE  bigfileuber
DATAFILE 'bigfileuber.dbf' SIZE 25M;

-- d)Set the undo tablespace to be used in the system

------------- 3
CREATE USER DBAUSER
IDENTIFIED BY "123456"
DEFAULT TABLESPACE uber
QUOTA UNLIMITED ON uber;

--asignar rol a usuario
GRANT DBA TO DBAUSER;

------------ 4 Create 2 profiles.
-- a) Profile 1: "clerk" password life 40 days, one session per user, 10 minutes idle, 4 failed login attempts
CREATE PROFILE clerk LIMIT
SESSIONS_PER_USER 1
IDLE_TIME 10
FAILED_LOGIN_ATTEMPTS 4
PASSWORD_LIFE_TIME 40 ;
--b )Profile 3: "development" password life 100 days, two session per user, 30 minutes idle, no failed login attempts
CREATE PROFILE development LIMIT
SESSIONS_PER_USER 2
IDLE_TIME 30
PASSWORD_LIFE_TIME 100 
FAILED_LOGIN_ATTEMPTS UNLIMITED;

------------- 5 Create 4 users, assign them the tablespace uber
CREATE USER user1
IDENTIFIED BY "user1"
DEFAULT TABLESPACE uber
QUOTA UNLIMITED ON uber;

CREATE USER user2
IDENTIFIED BY "user2"
DEFAULT TABLESPACE uber
QUOTA UNLIMITED ON uber;

CREATE USER user3
IDENTIFIED BY "user3"
DEFAULT TABLESPACE uber
QUOTA UNLIMITED ON uber;

CREATE USER user4
IDENTIFIED BY "user4"
DEFAULT TABLESPACE uber
QUOTA UNLIMITED ON uber;

--a) . 2 of them should have the clerk profile and the remaining the development profile, all the users should be allow to connect to the database.

ALTER USER user1 PROFILE clerk;
ALTER USER user2 PROFILE clerk;
ALTER USER user3 PROFILE development;
ALTER USER user4 PROFILE development;

-- b). Lock one user associate with clerk profile 
ALTER USER user1 ACCOUNT LOCK;




