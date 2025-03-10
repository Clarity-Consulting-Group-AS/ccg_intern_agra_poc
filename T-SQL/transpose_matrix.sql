-- Drop the procedure if it exists
IF OBJECT_ID('testuser.transpose_matrix', 'P') IS NOT NULL
    DROP PROCEDURE testuser.transpose_matrix;
GO

-- Create the stored procedure in the testuser schema
CREATE PROCEDURE testuser.transpose_matrix
AS
BEGIN
    -- Suppress the "1 row affected" messages
    SET NOCOUNT ON;

    -- Declare variables
    DECLARE @v_size INT = 3;
    DECLARE @v_i INT;
    DECLARE @v_j INT;

    -- Create temporary tables to store the matrix and transposed matrix
    CREATE TABLE #v_matrix (
        row INT,
        col INT,
        value INT
    );

    CREATE TABLE #v_transposed_matrix (
        row INT,
        col INT,
        value INT
    );

    -- Initialize the matrix
    SET @v_i = 1;
    WHILE @v_i <= @v_size
    BEGIN
        SET @v_j = 1;
        WHILE @v_j <= @v_size
        BEGIN
            INSERT INTO #v_matrix (row, col, value)
            VALUES (@v_i, @v_j, (@v_i - 1) * @v_size + @v_j);
            SET @v_j = @v_j + 1;
        END
        SET @v_i = @v_i + 1;
    END

    -- Transpose the matrix
    SET @v_i = 1;
    WHILE @v_i <= @v_size
    BEGIN
        SET @v_j = 1;
        WHILE @v_j <= @v_size
        BEGIN
            INSERT INTO #v_transposed_matrix (row, col, value)
            VALUES (@v_j, @v_i, (SELECT value FROM #v_matrix WHERE row = @v_i AND col = @v_j));
            SET @v_j = @v_j + 1;
        END
        SET @v_i = @v_i + 1;
    END

    -- Print the transposed matrix
    SET @v_i = 1;
    WHILE @v_i <= @v_size
    BEGIN
        SET @v_j = 1;
        WHILE @v_j <= @v_size
        BEGIN
            DECLARE @value INT;
            SELECT @value = value FROM #v_transposed_matrix WHERE row = @v_i AND col = @v_j;
            PRINT 'Element (' + CAST(@v_i AS NVARCHAR(10)) + ', ' + CAST(@v_j AS NVARCHAR(10)) + '): ' + CAST(@value AS NVARCHAR(10));
            SET @v_j = @v_j + 1;
        END
        SET @v_i = @v_i + 1;
    END

    -- Drop the temporary tables
    DROP TABLE #v_matrix;
    DROP TABLE #v_transposed_matrix;
END;
GO

-- Execute the stored procedure
DECLARE @RC int;
EXECUTE @RC = testuser.transpose_matrix;
GO