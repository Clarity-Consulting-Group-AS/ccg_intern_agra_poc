-- Drop the procedure if it exists
IF OBJECT_ID('testuser.find_min_max_values', 'P') IS NOT NULL
    DROP PROCEDURE testuser.find_min_max_values;
GO

-- Create the stored procedure in the testuser schema
CREATE PROCEDURE testuser.find_min_max_values
    @v_size INT,
    @v_max DECIMAL(38, 20) OUTPUT,
    @v_min DECIMAL(38, 20) OUTPUT
AS
BEGIN
    -- Suppress the "1 row affected" messages
    SET NOCOUNT ON;

    DECLARE @v_2d_array TABLE (id INT, value DECIMAL(38, 20));
    DECLARE @v_i INT;
    DECLARE @v_j INT;
    DECLARE @value DECIMAL(38, 20);

    SET @v_max = -999999;
    SET @v_min = 999999;

    -- Initialize the 2D array
    SET @v_i = 1;
    WHILE @v_i <= @v_size
    BEGIN
        SET @v_j = 1;
        WHILE @v_j <= @v_size
        BEGIN
            SET @value = CAST(RAND() * 100 AS DECIMAL(38, 20));
            INSERT INTO @v_2d_array (id, value) VALUES ((@v_i - 1) * @v_size + @v_j, @value);
            SET @v_j = @v_j + 1;
        END
        SET @v_i = @v_i + 1;
    END

    -- Find the maximum and minimum values
    SELECT @v_max = MAX(value), @v_min = MIN(value) FROM @v_2d_array;
END;
GO