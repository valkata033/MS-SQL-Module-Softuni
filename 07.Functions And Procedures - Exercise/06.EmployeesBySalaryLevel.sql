CREATE PROCEDURE usp_EmployeesBySalaryLevel (@levelOFSalary VARCHAR(10))
AS
BEGIN
	SELECT [FirstName],
	       [LastName]
	  FROM [Employees]
	 WHERE @levelOFSalary = [dbo].[ufn_GetSalaryLevel]([Salary])
END

