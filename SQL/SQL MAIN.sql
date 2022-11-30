--ALL SQL 
DROP DATABASE DMDD_FINAL_PORJECT_GROUP9;
CREATE DATABASE DMDD_FINAL_PORJECT_GROUP9;
USE DMDD_FINAL_PORJECT_GROUP9; 
GO

--ENCRYPTION KEYS
--Create Password protected Master key
	CREATE MASTER KEY 
	ENCRYPTION BY PASSWORD = 'DMDDProject_Group9';
--Create certificate to protect symmetric key
	CREATE CERTIFICATE GROUP9CER
	WITH SUBJECT = 'DMDD Project';
--Create symmetric key to encrypt data
	CREATE SYMMETRIC KEY GROUP9SMK
	WITH ALGORITHM = AES_256
	ENCRYPTION BY CERTIFICATE GROUP9CER;
GO

--ALL TABLES
--USER TABLE
CREATE TABLE [User]
(
    userId INT NOT NUll,
    email NVARCHAR(255),
    [location] VARCHAR(30),
    userType CHAR(1)
    CONSTRAINT user_PK PRIMARY KEY (userId), 
    CONSTRAINT chk_email CHECK (email like '%_@__%.__%'),
    CONSTRAINT chk_userType CHECK(userType IN ('R','U'))
)
--REGISTERED USER TABLE
CREATE TABLE [Registered_User]
(
    rUserId INT NOT NUll,
    firstname VARCHAR(30),
    lastname VARCHAR(30),
    username VARCHAR(30),
    contactNumber BIGINT,
    dateOfBirth DATE,
    gender CHAR(1),
    [password] VARCHAR(100),
    registeredUserType CHAR(1),
    CONSTRAINT Registered_User_PK PRIMARY KEY (rUserId),
    CONSTRAINT Registered_User_FK FOREIGN KEY (rUserId) REFERENCES [User](userId),
    CONSTRAINT chk_Registered_User CHECK(registeredUserType IN ('O','B','T')),
    CONSTRAINT chk_Contact_Length CHECK(LEN(contactNumber)=10)
)

--UNREGISTERED USER TABLE
CREATE TABLE [Unregistered_User]
(
    uUserId INT NOT NUll,
    CONSTRAINT Unregistered_User_PK PRIMARY KEY (uUserId),
    CONSTRAINT Unregistered_User_FK FOREIGN KEY (uUserId) REFERENCES [User](userId)
)

--LOGIN TABLE
CREATE TABLE [Login]
(
    loginId INT NOT NULL,
    rUserId INT NOT NULL,
    [timeStamp] DATE DEFAULT (GETDATE()) NOT NULL,
    CONSTRAINT Login_PK PRIMARY KEY (loginId),
    CONSTRAINT Login_FK FOREIGN KEY (rUserId) REFERENCES [Registered_User](rUserId)
)

--REQUIRMENTS TABLE
CREATE TABLE [Requirements]
(
    reqId INT NOT NULL,
    rUserId INT NOT NULL,
    reqDescription VARCHAR(100),
    CONSTRAINT Requirements_PK PRIMARY KEY (reqId),
    CONSTRAINT Requirements_FK FOREIGN KEY (rUserId) REFERENCES [Registered_User](rUserId)
)

--REGION REQUIREMNETS TABLE
CREATE TABLE [Region_Requirement]
(
    regionId INT NOT NULL,
    reqId INT NOT NULL,
    region VARCHAR(50),
    CONSTRAINT Region_Requirement_PK PRIMARY KEY (regionId),
    CONSTRAINT Region_Requirement_FK FOREIGN KEY (reqId) REFERENCES [Requirements](reqId)
)

--OWNER TABLE
CREATE TABLE [Owner]
(
    ownerId INT NOT NULL,
    CONSTRAINT Owner_PK PRIMARY KEY (ownerId),
    CONSTRAINT Owner_FK FOREIGN KEY (ownerId) REFERENCES [Registered_User](rUserId)
)

--BUYER TABLE
CREATE TABLE [Buyer]
(
    buyerId INT NOT NULL,
    CONSTRAINT Buyer_PK PRIMARY KEY (buyerId),
    CONSTRAINT BuyerFK FOREIGN KEY (buyerId) REFERENCES [Registered_User](rUserId)
)

--PROPERTY TABLE
CREATE TABLE [Property]
(
    propertyId INT NOT NULL,
    ownerId INT NOT NULL,
    houseNumber INT,
    street VARCHAR(20),
    region VARCHAR(30),
    city VARCHAR(30),
    zipcode INT,
    propertyOverview VARCHAR(1000),
    propertyType CHAR(1)
    CONSTRAINT Property_PK PRIMARY KEY (propertyId),
    CONSTRAINT Property_FK FOREIGN KEY (ownerId) REFERENCES [Owner](ownerId),
    CONSTRAINT chk_propertyType CHECK(propertyType IN ('R','S'))
)

--PROPERTY FOR SALE TABLE
CREATE TABLE [Property_Sell]
(
    sPropertyId INT NOT NULL,
    purchasePrice INT NOT NULL,
    CONSTRAINT Property_Sell_PK PRIMARY KEY (sPropertyId),
    CONSTRAINT Property_Sell_FK FOREIGN KEY (sPropertyId) REFERENCES [Property](propertyId)
)

--PROPERTY FOR RENT TABLE
CREATE TABLE [Property_Rent]
(
    rPropertyId INT NOT NULL,
    propertyRent INT NOT NULL,
    propertyRating DECIMAL,
    CONSTRAINT Property_Rent_PK PRIMARY KEY (rPropertyId),
    CONSTRAINT Property_Rent_FK FOREIGN KEY (rPropertyId) REFERENCES [Property](propertyId)
)

--AGREEMENT TABLE
CREATE TABLE [Lease_Agreement]
(
    agreementId INT NOT NULL,
    rPropertyId INT NOT NULL,
    numberOfTenants INT,
    securityDeposit INT, 
    agreementDate DATE,
    agreementPeriod INT,
    CONSTRAINT Lease_Agreement_PK PRIMARY KEY (agreementId),
    CONSTRAINT Lease_Agreement_Property_Rent_FK FOREIGN KEY (rPropertyId) REFERENCES [Property_Rent](rPropertyId)
)

--TENANT TABLE
CREATE TABLE [Tenant]
(
    tenantId INT NOT NULL,
    agreementId INT NOT NULL,
    CONSTRAINT Tenant_PK PRIMARY KEY (tenantId),
    CONSTRAINT Tenant_Registered_User_FK FOREIGN KEY (tenantId) REFERENCES [Registered_User](rUserId),
    CONSTRAINT Tenant_Lease_Agreement_FK FOREIGN KEY (agreementId) REFERENCES [Lease_Agreement](agreementId)
)


--CONTRACT TABLE
CREATE TABLE [Contract] --is associative?? composite key??
(
    contractId INT NOT NULL,
    buyerId INT NOT NULL,
    sPropertyId INT NOT NULL,
    realtorCommision INT,
    contarctDate DATE,
    CONSTRAINT Contract_PK PRIMARY KEY (contractId),
    CONSTRAINT Contract_Buyer_FK FOREIGN KEY (buyerId) REFERENCES [Buyer](buyerId),
    CONSTRAINT Contract_Property_Sell_FK FOREIGN KEY (sPropertyId) REFERENCES [Property_Sell](sPropertyId)
)

--PROPERTY FEATURE TABLE
CREATE TABLE [Property_Feature]
(
    featureId INT NOT NULL,
    propertyId INT NOT NULL,
    bedCount INT,
    bathCount INT,
    sqFtArea INT,
    parking BIT,
    laundry BIT,
    ac BIT,
    heater BIT,
    petFriendly BIT,
    CONSTRAINT Property_Features PRIMARY KEY (featureId),
    CONSTRAINT Property_Features_FK FOREIGN KEY (propertyId) REFERENCES [Property](propertyId)
)

--PAYMENTS TABLE
CREATE TABLE [Payments]
(
    paymentId INT NOT NULL,
    propertyId INT NOT NULL,
    rUserId INT NOT NULL,
    paymentMode VARCHAR(20),
    payableAmount INT,
    cardNumber BIGINT,
    cardExpiryDate DATE,
    paymentDate DATE,
    CONSTRAINT Payments_PK PRIMARY KEY (paymentId),
    CONSTRAINT Payments_Property_FK FOREIGN KEY (propertyId) REFERENCES [Property](propertyId),
    CONSTRAINT Payments_Registered_User_FK FOREIGN KEY (rUserId) REFERENCES [Registered_User](rUserId)

)

--USERLOG TABLE
CREATE TABLE [UserLog](
    userId INT,
    email VARCHAR(30),
    [location] VARCHAR(30),
    userType CHAR(1),
    [Status] VARCHAR(30),
    [dateTime] DATETIME
)
GO

--Triggers
--TRIGGER 1 -AFTER INSERT TRIGGER FOR USERS TABLE 
CREATE TRIGGER [User_INSERT] ON [User]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @userId INT, @email VARCHAR(30), @location VARCHAR(30),@userType CHAR(1)
    SELECT @userId = INSERTED.userId, @email = INSERTED.email ,@location = INSERTED.[location],@userType = INSERTED.userType
    FROM INSERTED

    INSERT INTO [UserLog]
    VALUES (@userId,@email,@location,@userType,'INSERTED',GETDATE())
END
GO
--TRIGGER 2 -AFTER DELETE TRIGGER FOR USRES TABLE 
CREATE TRIGGER [User_DELETE] ON [User]
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @userId INT, @email VARCHAR(30),@location VARCHAR(30),@userType CHAR(1)
    SELECT @userId = DELETED.userId, @email = DELETED.email,@location = DELETED.[location],@userType = DELETED.userType
    FROM DELETED

    INSERT INTO [UserLog]
    VALUES (@userId,@email,@location,@userType,'DELETED',GETDATE())
END
GO
--TRIGGER 3 -AFTER UPDATE TRIGGER FOR USER TABLE 
CREATE TRIGGER [User_UPDATE] ON [User]
    AFTER UPDATE
AS 
BEGIN
    SET NOCOUNT ON
    DECLARE @userId INT, @email VARCHAR(30),@location VARCHAR(30),@userType CHAR(1),@action VARCHAR(50)
    SELECT @userId = INSERTED.userId, @email = INSERTED.email ,@location = INSERTED.[location],@userType = INSERTED.userType
    FROM INSERTED
    IF UPDATE(email)
    SET @action = 'UPDATED email'
    IF UPDATE([location])
    SET @action = 'UPDATED location'
    IF UPDATE(userType)
    SET @action = 'UPDATED userType'

    INSERT INTO [UserLog]
    VALUES (@userId,@email,@location,@userType,@action,GETDATE())
END
GO



--RUN AFTER INSERT
-- QUERY TO LIST ALL PROPERTIES GROUPED BY OWNER NAME (NORMAL QUERY)
SELECT (r.firstname +' '+ r.lastname) Owner_Name, 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview,
p.propertyType
FROM [Registered_User] r 
JOIN
[Owner] o  ON
r.rUserId = o.ownerId
JOIN 
[Property] p ON 
o.ownerId = p.ownerId
WHERE 
propertyType IN ('S','R')
GROUP BY (r.firstname +' '+ r.lastname), 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview,
p.propertyType
ORDER BY Owner_Name;
GO


--VIEWS
--VIEW 1 -ALL LISTED PROPERTY VIEW
CREATE VIEW [PROPERTY LISTED] AS (SELECT (r.firstname +' '+ r.lastname) Owner_Name, 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview
FROM [Registered_User] r 
JOIN
[Owner] o  ON
r.rUserId = o.ownerId
JOIN 
[Property] p ON 
o.ownerId = p.ownerId
WHERE 
propertyType IN ('R','S'));
GO
--VIEW 2 -ALL PROPERTIES FOR SALE
CREATE VIEW [PROPERTY FOR SALE] AS (SELECT (r.firstname +' '+ r.lastname) Owner_Name, 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview,
ps.purchasePrice
FROM [Registered_User] r 
JOIN
[Owner] o  ON
r.rUserId = o.ownerId
JOIN 
[Property] p ON 
o.ownerId = p.ownerId
JOIN 
[Property_Sell] ps ON
ps.sPropertyId = p.propertyId);
GO
--VIEW 3 -ALL PROPERTIES FOR RENT
CREATE VIEW [PROPERTY FOR RENT] AS (SELECT (r.firstname +' '+ r.lastname) Owner_Name, 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview,
pr.propertyRating,
pr.propertyRent
FROM [Registered_User] r 
JOIN
[Owner] o  ON
r.rUserId = o.ownerId
JOIN 
[Property] p ON 
o.ownerId = p.ownerId
JOIN 
[Property_Rent] pr ON
pr.rPropertyId = p.propertyId);
GO


--PROCEDURES
-- PROCEDURE 1 -BUYER FILTER BY SQFTAREA AND PURCHASE PRICE
CREATE PROCEDURE [BUYER FILTER] 
@sqFtArea INT,
@purchasePrice INT
AS 
BEGIN 
SELECT (r.firstname +' '+ r.lastname) Owner_Name, 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview,
ps.purchasePrice,
pf.sqFtArea
FROM [Registered_User] r 
JOIN
[Owner] o  ON
r.rUserId = o.ownerId
JOIN 
[Property] p ON 
o.ownerId = p.ownerId
JOIN 
[Property_Sell] ps ON
ps.sPropertyId = p.propertyId
JOIN 
[Property_Feature] pf ON
ps.sPropertyId = pf.propertyId
WHERE 
pf.sqFtArea >= @sqFtArea AND ps.purchasePrice >= @purchasePrice
END
GO
--PROCEDURE 2 -CHECK THE USER AND SHOW PROPERTIES ACCORDINGLY 
CREATE PROCEDURE [USER CHECK(LISTED PROPERTIES)]
    @username nvarchar(30)
AS 
BEGIN
    DECLARE @type CHAR(1),@fname VARCHAR(30),@lname VARCHAR(30)
    
    SELECT @type = registeredUserType 
    FROM
    [Registered_User] 
    WHERE username = @username

    SELECT @fname=firstname
    FROM
    [Registered_User] 
    WHERE username = @username

    SELECT @lname=lastname
    FROM
    [Registered_User] 
    WHERE username = @username

    IF @type='O'
    BEGIN
        SELECT * FROM [PROPERTY LISTED]
        WHERE (@fname+' '+@lname) = Owner_Name
    END
    IF @type='B'
    BEGIN
        SELECT * FROM [PROPERTY FOR SALE]
    END
     IF @type='T'
    BEGIN
        SELECT * FROM [PROPERTY FOR RENT]
    END
END
GO
-- PROCEDURE 3 -TENTANT FILTER BY PROPERTY FEATURE
CREATE PROCEDURE [TENANT RENTING FILTER]
@bedCount INT,
@bathCount INT,
@parking BIT,
@laundry BIT,
@ac BIT,
@heater BIT,
@petFriendly BIT 
AS
BEGIN
SELECT (r.firstname +' '+ r.lastname) Owner_Name, 
p.houseNumber,
p.street,
p.region,
p.zipcode,
p.propertyOverview,
pr.propertyRent,
pf.sqFtArea,
pf.bedCount,
pf.bathCount
FROM [Registered_User] r 
JOIN
[Owner] o  ON
r.rUserId = o.ownerId
JOIN 
[Property] p ON 
o.ownerId = p.ownerId
JOIN 
[Property_Rent] pr ON
pr.rPropertyId = p.propertyId
JOIN 
[Property_Feature] pf ON
pr.rPropertyId = pf.propertyId
WHERE 
    (
        pf.bedCount= @bedCount AND 
        pf.bathCount = @bathCount AND
        pf.parking = @parking AND 
        pf.laundry = @laundry AND 
        pf.ac= @ac AND 
        pf.heater = @heater AND
        pf.petFriendly = @petFriendly 
    )
END
GO
--PROCEDURE 4 -CHECK IF THE USER IS REGISTERED OR NOT
CREATE PROCEDURE usercheck (
    @email VARCHAR(30)
)
AS
BEGIN
   DECLARE @EMAILCOUNT INT
        SELECT @EMAILCOUNT= COUNT(*) FROM 
        [Registered_User] r JOIN 
        [User] u ON 
        r.rUserId = u.userId
        WHERE u.email = @email
        IF @EMAILCOUNT = 1
            BEGIN
                PRINT('ALREADY REGISTERED')
            END
        ELSE
            PRINT('PLEASE REGISTER')
END
GO


-- COMPUTED FUNCTION TO GET AGE ACCORDING TO USER TYPE
CREATE FUNCTION GetAge (
    @type CHAR(1)
)
RETURNS TABLE
AS
RETURN
SELECT r.firstname+' '+r.lastname [NAME], (YEAR(GETDATE()) - YEAR(r.dateOfBirth)) [Age] FROM [Registered_User] r WHERE r.registeredUserType = @type;
GO


-- ALL NON CLUSTERED INDEXES
CREATE NONCLUSTERED INDEX IDX_Property_State
ON [Property] (region ASC)

CREATE NONCLUSTERED INDEX IDX_RUSER_TYPE
ON [Registered_User] (registeredUserType ASC)

CREATE NONCLUSTERED INDEX IDX_Property_Type
ON [Property] (propertyType ASC)

CREATE NONCLUSTERED INDEX IDX_PAYMENT_MODE
ON [Payments] (paymentMode ASC)

CREATE NONCLUSTERED INDEX IDX_PURCHASE_PRICE
ON [Property_Sell] (purchasePrice ASC)

CREATE NONCLUSTERED INDEX IDX_PROPERTY_RENT
ON [Property_Rent] (propertyRent ASC)
GO

--CHECKS
--CHECK INSERT TRIGGER
INSERT INTO [User](userID,email,[location],userType) VALUES (51,'yashashreepatel@gmail.com','California','U');
INSERT INTO [User](userID,email,[location],userType) VALUES (52,'sohamshah@gmail.com','Washigton','R');
INSERT INTO [User](userID,email,[location],userType) VALUES (53,'aarushi@gmail.com','Hawaii','U');
GO
SELECT * FROM [UserLog];

--CHECK UPDATE TRIGGER
UPDATE [User]
SET [userType] = 'R' WHERE userID = 51;
UPDATE [User]
SET [location] = 'Connecticut' WHERE userID = 52;
UPDATE [User]
SET [email] = 'arushibhutaiya@gmail.com' WHERE userID = 53;
GO
SELECT * FROM [UserLog];

--CHECK DELETE TRIGGER
DELETE FROM [User] WHERE userID = 53;
GO
SELECT * FROM [UserLog];

--CHECK VIEWS 
SELECT * FROM [PROPERTY FOR RENT];
SELECT * FROM [PROPERTY FOR SALE];
SELECT * FROM [PROPERTY LISTED];
GO

--CHECK PROC 1 (BUYER FILTER BY SQFTAREA AND PURCHASE PRICE)
EXEC [BUYER FILTER] 200, 300000;
GO

--CHECK PROC 2 (CHECK THE USER AND SHOW PROPERTIES ACCORDINGLY)
EXEC [USER CHECK(LISTED PROPERTIES)] @username= 'igorcherry'; --BUYER
EXEC [USER CHECK(LISTED PROPERTIES)] @username= 'omarnewman'; --TENANT
EXEC [USER CHECK(LISTED PROPERTIES)] @username= 'hedwigmack'; --OWNER HEDWIGMACK
EXEC [USER CHECK(LISTED PROPERTIES)] @username= 'griffindale70' --OWNER Griffin DALE
GO

--CHECK PROC 3 (TENTANT FILTER BY PROPERTY FEATURE)
EXEC[TENANT RENTING FILTER] @bedCount=1,@bathCount=1,@parking=1,@laundry=1,@ac=0,@heater=0,@petFriendly=0;
GO

--CHECK PROC 4 (CHECK IF THE USER IS REGISTERED OR NOT)
EXEC usercheck 'soham@gmail.com';
EXEC usercheck 'hedwigmack@gmail.com';
GO

--CHECK FUNCTION (COMPUTED FUNCTION TO GET AGE ACCORDING TO USER TYPE)
SELECT * FROM GetAge('T')
SELECT * FROM GetAge('B')
SELECT * FROM GetAge('O')
GO

--CHECK ENCRYPTION & DECRYPTION
--Add Password Encrypt Column
ALTER TABLE [Registered_User]
ADD [Password_Encrypt] VARBINARY(max);
GO
--Update Password column to encrypt
    UPDATE [Registered_User] 
    set [Password_Encrypt] = EncryptByKey(Key_GUID('GROUP9SMK'),[password]);
--Open symmetric key
	OPEN SYMMETRIC KEY GROUP9SMK
	DECRYPTION BY CERTIFICATE GROUP9CER;
--Decrypted Password  Query
SELECT rUserId, firstname,lastname,[password],[Password_Encrypt], 
    CONVERT(varchar, DecryptByKey([Password_Encrypt]))   
    AS 'Decrypted password'  
    FROM [Registered_User];  
GO
