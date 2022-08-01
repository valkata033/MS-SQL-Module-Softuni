--Problem 1

CREATE TABLE Sizes(
	Id INT PRIMARY KEY IDENTITY,
	[Length] INT CHECK([Length] BETWEEN 10 AND 25) NOT NULL,
	RingRange DECIMAL(18,2) CHECK(RingRange BETWEEN 1.5 AND 7.5) NOT NULL
)

CREATE TABLE Tastes(
	Id INT PRIMARY KEY IDENTITY,
	TasteType VARCHAR(20) NOT NULL,
	TasteStrength VARCHAR(15) NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL,
)

CREATE TABLE Brands(
	Id INT PRIMARY KEY IDENTITY,
	BrandName VARCHAR(30) UNIQUE NOT NULL,
	BrandDescription VARCHAR(MAX)
)

CREATE TABLE Cigars(
	Id INT PRIMARY KEY IDENTITY,
	CigarName VARCHAR(80) NOT NULL,
	BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
	TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL,
	SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
	PriceForSingleCigar MONEY NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL,
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	Town VARCHAR(30) NOT NULL,
	Country NVARCHAR(30) NOT NULL,
	Streat NVARCHAR(100) NOT NULL,
	ZIP VARCHAR(20) NOT NULL,
)

CREATE TABLE Clients(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE ClientsCigars(
	ClientId INT FOREIGN KEY REFERENCES Clients(Id),
	CigarId INT FOREIGN KEY REFERENCES Cigars(Id),
	PRIMARY KEY (ClientId, CigarId)
)


--Problem 2

INSERT INTO Cigars(CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL)
	 VALUES
	 ('COHIBA ROBUSTO',	9,	1,	5,	15.50,	'cohiba-robusto-stick_18.jpg'),
	 ('COHIBA SIGLO I',	9,	1,	10,	410.00,	'cohiba-siglo-i-stick_12.jpg'),
	 ('HOYO DE MONTERREY LE HOYO DU MAIRE',	14,	5,	11,	7.50,	'hoyo-du-maire-stick_17.jpg'),
	 ('HOYO DE MONTERREY LE HOYO DE SAN JUAN',	14,	4,	15,	32.00,	'hoyo-de-san-juan-stick_20.jpg'),
	 ('TRINIDAD COLONIALES',	2,	3,	8,	85.21,	'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses(Town, Country, Streat, ZIP)
	 VALUES
	 ('Sofia',	'Bulgaria',	'18 Bul. Vasil levski',	1000),
	 ('Athens',	'Greece',	'4342 McDonald Avenue',	10435),
	 ('Zagreb',	'Croatia',	'4333 Lauren Drive',	10000)

--Problem 3

UPDATE Cigars
   SET PriceForSingleCigar = PriceForSingleCigar * 1.20
 WHERE TastId = 1

UPDATE Brands
   SET BrandDescription = 'New description'
 WHERE BrandDescription IS NULL

--Problem 4
DELETE 
  FROM Clients
 WHERE AddressId IN (
						SELECT Id 
						  FROM Addresses
						 WHERE LEFT(Country, 1) = 'C'
					)
DELETE 
  FROM Addresses
 WHERE LEFT(Country, 1) = 'C'

--Problem 5

  SELECT CigarName,
	     PriceForSingleCigar,
         ImageURL
    FROM Cigars
ORDER BY PriceForSingleCigar, CigarName DESC

--Problem 6

   SELECT c.Id,
		  CigarName,
		  PriceForSingleCigar,
		  TasteType,
	      TasteStrength
     FROM Cigars AS [c]
LEFT JOIN [Tastes] AS [t] ON [c].[TastId] = [t].[Id]
    WHERE TasteType IN ('Earthy', 'Woody')
 ORDER BY PriceForSingleCigar DESC

 --Problem 7

  SELECT Id,
         CONCAT(FirstName, ' ', LastName) 
	  AS ClientName,
	     Email
    FROM Clients
   WHERE NOT EXISTS (SELECT 1 FROM ClientsCigars WHERE ClientId = Id)
ORDER BY ClientName

--Problem 8

SELECT TOP (5) 
		  CigarName,
		  PriceForSingleCigar,
		  ImageURL 
     FROM Cigars AS [c]
LEFT JOIN [Sizes] AS [s] ON [c].[SizeId] = [s].[Id]
    WHERE [Length] >= 12 AND
		  (CigarName LIKE '%ci%' 
		  OR PriceForSingleCigar > 50
		  AND RingRange > 2.55)
 ORDER BY CigarName, PriceForSingleCigar DESC

 --Problem 9

  SELECT 
		 CONCAT(FirstName, ' ', LastName) AS FullName,
	     Country,
		 ZIP,
		 CONCAT('$', 
				(SELECT 
					   MAX(PriceForSingleCigar)
				  FROM Cigars AS [cg]
				  JOIN ClientsCigars AS [cc] 
					ON [cg].[Id] = [cc].[CigarId] AND [cc].[ClientId] = [c].[Id] 
				)) AS CigarPrice
    FROM Clients AS [c]
    JOIN Addresses AS [a] ON [c].[AddressId] = [a].[Id]
   WHERE ISNUMERIC(a.ZIP) = 1 
ORDER BY FullName

--Problem 10

   SELECT LastName,
		  AVG([Length]) AS CigarLength,
		  CEILING(AVG(RingRange)) AS CiagrRingRange
     FROM Clients AS [c]
     JOIN ClientsCigars AS [cc] ON [c].[Id] = [cc].[ClientId]
     JOIN Cigars AS [cg] ON [cc].[CigarId] = [cg].[Id]
     JOIN Sizes AS [s] ON [cg].[SizeId] = [s].[Id]
    WHERE [cc].[CigarId] IS NOT NULL
 GROUP BY LastName
 ORDER BY CigarLength DESC

--Problem 11
 GO

 CREATE FUNCTION udf_ClientWithCigars(@name VARCHAR(30)) 
 RETURNS INT 
 AS
 BEGIN 
	DECLARE @cigarsCnt INT;
	SET @cigarsCnt = (
						SELECT COUNT(*)
						  FROM ClientsCigars
						 WHERE ClientId IN (
											SELECT Id
											  FROM Clients
											 WHERE FirstName = @Name
										   )
					 )

	RETURN @cigarsCnt
 END

 GO

--Problem 12

CREATE PROCEDURE usp_SearchByTaste @taste VARCHAR(20)
AS
BEGIN
	SELECT CigarName,
	       CONCAT('$', c.PriceForSingleCigar) AS Price,
	       TasteType,
	       c.CigarName AS BrandName,
	       CONCAT(s.[Length], ' ', 'cm') AS CigarLength,
	       CONCAT(s.RingRange, ' ', 'cm') AS CigarRingRange
	  FROM Cigars AS c
	  JOIN Tastes AS t ON c.TastId = t.Id
	  JOIN Sizes AS s ON c.SizeId = s.Id
	 WHERE t.TasteType = @taste
  ORDER BY CigarLength ASC, CigarRingRange DESC
END

