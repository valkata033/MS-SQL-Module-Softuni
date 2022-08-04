CREATE DATABASE Zoo

USE Zoo

--Problem 1

CREATE TABLE Owners(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE AnimalTypes(
	Id INT PRIMARY KEY IDENTITY,
	AnimalType VARCHAR(30) NOT NULL
)

CREATE TABLE Cages(
	Id INT PRIMARY KEY IDENTITY,
	AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE Animals(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	BirthDate DATE NOT NULL,
	OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
	AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)

CREATE TABLE AnimalsCages(
	CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
	PRIMARY KEY (CageId, AnimalId)
)

CREATE TABLE VolunteersDepartments(
	Id INT PRIMARY KEY IDENTITY,
	DepartmentName VARCHAR(30) NOT NULL
)

CREATE TABLE Volunteers(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PhoneNumber VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
	DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)

--Problem 2

INSERT INTO Volunteers([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
	 VALUES 
	 ('Anita Kostova',	'0896365412',	'Sofia, 5 Rosa str.',	15,	1),
	 ('Dimitur Stoev',	'0877564223',	null,	42,	4),
	 ('Kalina Evtimova','0896321112',	'Silistra, 21 Breza str.',	9,	7),
	 ('Stoyan Tomov',	'0898564100',	'Montana, 1 Bor str.',	18,	8),
	 ('Boryana Mileva',	'0888112233',	null,	31,	5)

INSERT INTO Animals([Name], BirthDate, OwnerId, AnimalTypeId)
	 VALUES
	 ('Giraffe',	'2018-09-21',	21,	1),
	 ('Harpy Eagle',	'2015-04-17',	15,	3),
	 ('Hamadryas Baboon',	'2017-11-02',	null,	1),
	 ('Tuatara',	'2021-06-30',	2,	4)

--Problem 3

UPDATE Animals
   SET OwnerId = (
				SELECT Id
				  FROM Owners
				 WHERE [Name] = 'Kaloqn Stoqnov'
				 )
 WHERE OwnerId IS NULL

--Problem 4

DELETE FROM Volunteers
 WHERE DepartmentId = (
						SELECT Id 
						  FROM VolunteersDepartments
						 WHERE DepartmentName = 'Education program assistant'
					  )

DELETE FROM VolunteersDepartments
 WHERE DepartmentName = 'Education program assistant'

--Problem 5

  SELECT [Name],
	     PhoneNumber,
	     [Address],
	     AnimalId,
	     DepartmentId
    FROM Volunteers
ORDER BY [Name], AnimalId, DepartmentId

--Problem 6

   SELECT a.[Name],
		  ant.AnimalType,
		  FORMAT(a.BirthDate, 'dd.MM.yyyy') AS BirthDate
     FROM Animals AS a
LEFT JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
ORDER BY a.[Name]

--Problem 7

SELECT TOP (5) o.[Name],
		   COUNT(a.Id) AS CountOfAnimals
      FROM Owners AS o
 LEFT JOIN Animals AS a ON a.OwnerId = o.Id
  GROUP BY o.[Name]
  ORDER BY CountOfAnimals DESC, o.[Name]

--Problem 8

   SELECT CONCAT(o.[Name], '-', a.[Name]) AS OwnersAnimals,
		  o.PhoneNumber,
		  c.Id
     FROM Animals AS a
LEFT JOIN Owners AS o ON a.OwnerId = o.Id
LEFT JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
LEFT JOIN AnimalsCages AS ac ON a.Id = ac.AnimalId
LEFT JOIN Cages AS c ON ac.CageId = c.Id
    WHERE ant.AnimalType = 'Mammals'
	  AND a.OwnerId IS NOT NULL
 ORDER BY o.[Name], a.[Name] DESC

--Problem 9

   SELECT v.[Name],
		  v.PhoneNumber,
		  SUBSTRING(v.[Address], CHARINDEX(',', v.[Address]) + 2, 50) AS [Address]
     FROM Volunteers AS v
LEFT JOIN VolunteersDepartments AS vd ON v.DepartmentId = vd.Id
    WHERE vd.DepartmentName = 'Education program assistant' 
		  AND v.[Address] LIKE '%Sofia%'
 ORDER BY v.[Name]

--Problem 10

   SELECT a.[Name],
		  DATEPART(YEAR, a.BirthDate) AS BirthYear,
		  ant.AnimalType
	 FROM Animals AS a
LEFT JOIN AnimalTypes AS ant ON a.AnimalTypeId = ant.Id
	WHERE OwnerId IS NULL
		  AND DATEPART(YEAR, '01/01/2022') - DATEPART(YEAR, a.BirthDate) < 5
		  AND ant.AnimalType <> 'Birds'
 ORDER BY a.[Name]

--Problem 11
GO

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT 
AS 
BEGIN
	DECLARE @departmentId INT;
	SET @departmentId = 
	(
	SELECT Id 
	  FROM VolunteersDepartments
	 WHERE DepartmentName = @VolunteersDepartment
	)

	DECLARE @countOfVolunteers INT;
	SET @countOfVolunteers = 
	(
	SELECT COUNT(*)
	  FROM Volunteers
	 WHERE DepartmentId = @departmentId
	)

	RETURN @countOfVolunteers;
END

--Problem 12
--Does not work with ownerId null!
GO
CREATE PROCEDURE usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
BEGIN

	SELECT @AnimalName AS [Name],
		   CASE
			 WHEN a.OwnerId IS NOT NULL THEN o.[Name]
			 ELSE 'For adoption'
		   END AS OwnerName
	  FROM Animals AS a
 LEFT JOIN Owners AS o ON a.OwnerId = o.Id
	 WHERE o.Id = (
				   SELECT a.OwnerId
					 FROM Animals AS a
					WHERE a.[Name] = @AnimalName
				  )
END

GO 

EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'

EXEC usp_AnimalsWithOwnersOrNot 'Hippo'