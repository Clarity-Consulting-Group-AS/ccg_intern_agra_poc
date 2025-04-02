CREATE PROCEDURE GetAllEmployees
AS
BEGIN
    SELECT EmployeeID, FirstName, LastName, Title, HireDate
    FROM Employees;
END;