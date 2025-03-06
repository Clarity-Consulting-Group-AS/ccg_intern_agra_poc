-- Check if the type already exists, if not, create it
IF NOT EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 't_array')
BEGIN
    CREATE TYPE TESTUSER.t_array AS TABLE 
    (
        value NVARCHAR(3900)
    );
END;
GO

-- Drop the function if it exists
IF OBJECT_ID('TESTUSER.LAG_ARRAY', 'FN') IS NOT NULL
    DROP FUNCTION TESTUSER.LAG_ARRAY;
GO

-- Create the function
CREATE FUNCTION TESTUSER.LAG_ARRAY 
(
    @p_in_string NVARCHAR(4000), 
    @p_delim NVARCHAR(50)
)
RETURNS @result TABLE (value NVARCHAR(3900))
AS
BEGIN
    DECLARE @pos INT;
    DECLARE @lv_str NVARCHAR(4000) = @p_in_string;
    DECLARE @substring NVARCHAR(4000);

    -- Find the position of the first occurrence
    SET @pos = CHARINDEX(@p_delim, @lv_str);
    IF @pos = 0
    BEGIN
        INSERT INTO @result (value) VALUES (@lv_str);
    END

    -- Loop as long as there are more occurrences
    WHILE @pos != 0
    BEGIN
        -- Create array of strings
        SET @substring = SUBSTRING(@lv_str, 1, @pos - 1);
        INSERT INTO @result (value) VALUES (@substring);
        
        -- Remove the processed occurrence
        SET @lv_str = SUBSTRING(@lv_str, @pos + 1, LEN(@lv_str));
        
        -- Find the position of the next occurrence
        SET @pos = CHARINDEX(@p_delim, @lv_str);
        
        -- No more occurrences? Add the last element.
        IF @pos = 0
        BEGIN
            INSERT INTO @result (value) VALUES (@lv_str);
        END
    END
    
    RETURN;
END;
GO