-- Drop the function if it exists
IF OBJECT_ID('TESTUSER.REVERSE_STRING', 'FN') IS NOT NULL
    DROP FUNCTION TESTUSER.REVERSE_STRING;
GO

-- Create the function
CREATE FUNCTION TESTUSER.REVERSE_STRING 
(
    @p_string NVARCHAR(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE @result NVARCHAR(4000) = '';
    DECLARE @len INT = LEN(@p_string);
    DECLARE @i INT = 1;

    -- Loop to reverse the string
    WHILE @i <= @len
    BEGIN
        SET @result = SUBSTRING(@p_string, @i, 1) + @result;
        SET @i = @i + 1;
    END

    RETURN @result;
END;
GO
