-- Drop the procedure if it exists
IF OBJECT_ID('testuser.find_pairs_with_sum', 'P') IS NOT NULL
    DROP PROCEDURE testuser.find_pairs_with_sum;
GO

-- Create the stored procedure in the testuser schema
CREATE PROCEDURE testuser.find_pairs_with_sum
    @v_target_sum INT
AS
BEGIN
    -- Suppress the "1 row affected" messages
    SET NOCOUNT ON;

    DECLARE @v_numbers TABLE (id INT, value INT);
    DECLARE @v_i INT;
    DECLARE @v_j INT;
    DECLARE @value_i INT;
    DECLARE @value_j INT;
    DECLARE @count INT;

    -- Initialize the array
    INSERT INTO @v_numbers (id, value) VALUES
    (1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
    (6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

    -- Get the count of numbers
    SELECT @count = COUNT(*) FROM @v_numbers;

    -- Find unique pairs of numbers whose sum is equal to @v_target_sum
    SET @v_i = 1;
    WHILE @v_i <= @count
    BEGIN
        SET @v_j = @v_i + 1;
        WHILE @v_j <= @count
        BEGIN
            SELECT @value_i = value FROM @v_numbers WHERE id = @v_i;
            SELECT @value_j = value FROM @v_numbers WHERE id = @v_j;
            IF @value_i + @value_j = @v_target_sum
            BEGIN
                PRINT 'Pair found: ' + CAST(@value_i AS VARCHAR) + ', ' + CAST(@value_j AS VARCHAR);
            END
            SET @v_j = @v_j + 1;
        END
        SET @v_i = @v_i + 1;
    END
END;
GO