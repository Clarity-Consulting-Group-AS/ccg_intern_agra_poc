CREATE PROCEDURE testuser.INSERT_AGRO_RUN_LOG 
    @l_KALLER NVARCHAR(150),
    @new_status NVARCHAR(2) OUTPUT
AS
BEGIN
    DECLARE @sqlerr NVARCHAR(150);
    DECLARE @l_KJORE_TID NVARCHAR(8);
    DECLARE @l_KJORE_DAG INT;

    BEGIN TRY
        -- Get the current time and date
        SET @l_KJORE_TID = CONVERT(NVARCHAR(8), GETDATE(), 108);
        SET @l_KJORE_DAG = CONVERT(INT, FORMAT(GETDATE(), 'yyyyMMdd'));

        -- Insert into AGRO_RUN_LOG
        INSERT INTO testuser.AGRO_RUN_LOG (KALLER, KJORE_DAG, KJORE_TID)
        VALUES (@l_KALLER, @l_KJORE_DAG, @l_KJORE_TID);

        -- Commit the transaction
        SET @new_status = 'ok';
    END TRY
    BEGIN CATCH
        -- Handle the exception
        SET @sqlerr = LEFT(ERROR_MESSAGE(), 150);
        SET @new_status = 'Nok';

        -- Insert into AGRO_ERR_LOG
        INSERT INTO testuser.AGRO_ERR_LOG (KALLER, SQLERR, KJORE_TID)
        VALUES (@l_KALLER, @sqlerr, @l_KJORE_TID);

        -- Commit the transaction
    END CATCH;
END;
GO