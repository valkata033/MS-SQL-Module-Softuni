CREATE DATABASE Airport

--Problem 1

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) UNIQUE NOT NULL,
	Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) UNIQUE NOT NULL,
	LastName VARCHAR(30) UNIQUE NOT NULL,
	Age TINYINT CHECK(Age BETWEEN 21 AND 62) NOT NULL,
	Rating FLOAT CHECK(Rating BETWEEN 0.0 AND 10.0)
)

CREATE TABLE AircraftTypes(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) UNIQUE NOT NULL,
)

CREATE TABLE Aircraft(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR(1) NOT NULL,
	TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)

CREATE TABLE PilotsAircraft(
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
	PRIMARY KEY (AircraftId, PilotId)
)

CREATE TABLE Airports(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) UNIQUE NOT NULL,
	Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations(
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
	[Start] DATETIME NOT NULL,
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PassengerId	INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	TicketPrice DECIMAL(18,2) DEFAULT(15) NOT NULL
)

--Problem 2

INSERT INTO Passengers(FullName, Email)
  SELECT CONCAT(FirstName, ' ', LastName) AS FullName,
		 CONCAT(FirstName, LastName, '@gmail.com') AS Email
	FROM Pilots
   WHERE Id BETWEEN 5 AND 15
	 
--Problem 3

UPDATE Aircraft
   SET Condition = 'A'
 WHERE (Condition IN ('C', 'B')) AND
	   (FlightHours IS NULL OR FlightHours <= 100) AND
	   ([Year] >= 2013)

--Problem 4

DELETE FROM Passengers
 WHERE LEN(FullName) <= 10 

--Problem 5

  SELECT Manufacturer,
	     Model,
	     FlightHours,
	     Condition
    FROM Aircraft
ORDER BY FlightHours DESC

--Problem 6

   SELECT FirstName,
		  LastName,
		  Manufacturer,
		  Model,
		  FlightHours
     FROM Pilots AS p
LEFT JOIN PilotsAircraft AS pa ON p.Id = pa.PilotId
LEFT JOIN Aircraft AS a ON pa.AircraftId = a.Id
	WHERE FlightHours IS NOT NULL 
		  AND FlightHours <= 304
 ORDER BY FlightHours DESC, FirstName

--Problem 7

SELECT TOP (20) fd.Id AS DestinationId,
	    fd.[Start],
		p.FullName,
		a.AirportName,
		fd.TicketPrice
   FROM FlightDestinations AS fd
   JOIN Passengers AS p ON fd.PassengerId = p.Id
   JOIN Airports AS a ON fd.AirportId = a.Id
   WHERE DATEPART(DAY FROM fd.[Start]) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName	
   
--Problem 8

  SELECT * 
    FROM ( 
		  SELECT a.Id AS AircraftId,
				 a.Manufacturer,
				 a.FlightHours,
				 COUNT(a.Id) AS FlightDestinationsCount,
				 ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice
			FROM Aircraft AS a
			JOIN FlightDestinations AS fd ON a.Id = fd.AircraftId
		GROUP BY a.Id, a.Manufacturer, a.FlightHours
	     ) AS AircraftQuery
   WHERE FlightDestinationsCount >= 2
ORDER BY FlightDestinationsCount DESC, AircraftId

--Problem 9

  SELECT * 
    FROM (
			SELECT p.FullName,
				   COUNT(fd.PassengerId) AS CountOfAircraft,
				   SUM(fd.TicketPrice) AS TotalPayed
			  FROM Passengers AS p
			  JOIN FlightDestinations As fd ON p.Id = fd.PassengerId
			  JOIN Aircraft AS a ON fd.AircraftId = a.Id
		  GROUP BY FullName
		 ) AS PAssengersQuery
   WHERE CountOfAircraft > 1 
	     AND SUBSTRING(FullName, 2, 1) = 'a'
ORDER BY FullName

--Problem 10

  SELECT a.AirportName ,
   	     fd.[Start] AS DayTime,
   	     fd.TicketPrice,
   	     p.FullName,
   	     ac.Manufacturer,
   	     ac.Model
    FROM FlightDestinations AS fd
    JOIN Airports AS a ON fd.AirportId = a.Id
    JOIN Passengers AS p ON fd.PassengerId = p.Id
    JOIN Aircraft AS ac ON fd.AircraftId = ac.Id
   WHERE DATEPART(HOUR, fd.[Start]) BETWEEN 6 AND 20
	     AND TicketPrice > 2500
ORDER BY Model

--Problem 11
GO

CREATE FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT 
AS
BEGIN
	DECLARE @destinationCount INT;
	SET @destinationCount = 
	(
	 SELECT COUNT(*)
	   FROM FlightDestinations AS fd
	  WHERE fd.PassengerId = (
							 SELECT Id
							   FROM Passengers
							  WHERE Email = @email
							 )
	)

	RETURN @destinationCount
END

GO

--Problem 12

CREATE PROCEDURE usp_SearchByAirportName @airportName VARCHAR(70)
AS
BEGIN
	SELECT a.AirportName,
		   p.FullName,
		   (CASE 
				WHEN TicketPrice <= 400 THEN 'Low'
				WHEN TicketPrice BETWEEN 401 AND 1500 THEN 'Medium'
				WHEN TicketPrice >= 1501 THEN 'High'
		   END)
		AS LevelOfTickerPrice, 
		   ac.Manufacturer,
		   ac.Condition,
		   act.TypeName
	  FROM FlightDestinations AS fd
	  JOIN Passengers AS p ON fd.PassengerId = p.Id
	  JOIN Airports AS a ON fd.AirportId = a.Id
	  JOIN Aircraft AS ac ON fd.AircraftId = ac.Id
	  JOIN AircraftTypes AS act ON ac.TypeId = act.Id
	 WHERE AirportName = @airportName
  ORDER BY Manufacturer, p.FullName

END

GO

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'