CREATE PROCEDURE testuser.calculate_factorial
    @p_number INT,
    @p_result INT OUTPUT
AS
BEGIN
    DECLARE @v_counter INT = 1;
    SET @p_result = 1;

    -- Loop to calculate factorial
    WHILE @v_counter <= @p_number
    BEGIN
        SET @p_result = @p_result * @v_counter;
        SET @v_counter = @v_counter + 1;
    END
END;
GO