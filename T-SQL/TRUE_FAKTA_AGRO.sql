-- Drop the procedures if they already exist
IF OBJECT_ID('TESTUSER.Insert_FAKT_AGRO', 'P') IS NOT NULL
    DROP PROCEDURE TESTUSER.Insert_FAKT_AGRO;
GO

IF OBJECT_ID('TESTUSER.Insert_FAKT_AGRO_AGG_TOT', 'P') IS NOT NULL
    DROP PROCEDURE TESTUSER.Insert_FAKT_AGRO_AGG_TOT;
GO

IF OBJECT_ID('TESTUSER.pAgroFaktProcedure', 'P') IS NOT NULL
    DROP PROCEDURE TESTUSER.pAgroFaktProcedure;
GO

IF OBJECT_ID('TESTUSER.pAgroFaktAggTotProcedure', 'P') IS NOT NULL
    DROP PROCEDURE TESTUSER.pAgroFaktAggTotProcedure;
GO

IF OBJECT_ID('TESTUSER.pAgroFakt', 'P') IS NOT NULL
    DROP PROCEDURE TESTUSER.pAgroFakt;
GO

IF OBJECT_ID('TESTUSER.pAgroFaktAggTot', 'P') IS NOT NULL
    DROP PROCEDURE TESTUSER.pAgroFaktAggTot;
GO

-- Create the Insert_FAKT_AGRO procedure
CREATE PROCEDURE TESTUSER.Insert_FAKT_AGRO
    @iID Numeric(38, 0),
    @sDATO DATE,
    @sINST_CLOSE VARCHAR(26),
    @iINST_VOLUM FLOAT,
    @iINSTRUMENT FLOAT,
    @new_status NVARCHAR(255) OUTPUT,
    @caller NVARCHAR(150)
AS
BEGIN
    BEGIN TRY
       BEGIN TRANSACTION;
        INSERT INTO TESTUSER.FAKT_AGRO (ID,DATO, INST_CLOSE, INST_VOLUM, INSTRUMENT)
        VALUES (@iID,@sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @new_status = SUBSTRING(ERROR_MESSAGE(), 1, 150);
        -- Use correct column names in the AGRO_ERR_LOG table
        INSERT INTO TESTUSER.AGRO_ERR_LOG (Kaller, sqlerr)
        VALUES (@caller, @new_status);
        COMMIT;
    END CATCH;
END;
GO

-- Create the Insert_FAKT_AGRO_AGG_TOT procedure
CREATE PROCEDURE TESTUSER.Insert_FAKT_AGRO_AGG_TOT
    @iINSTRUMENT FLOAT,
    @sNAVN NVARCHAR(255),
    @iVOLUM FLOAT,
    @new_status NVARCHAR(255) OUTPUT,
    @caller NVARCHAR(150)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO TESTUSER.FAKT_AGRO_AGG_TOT (INSTRUMENT, NAVN, VOLUM)
        VALUES (@iINSTRUMENT, @sNAVN, @iVOLUM);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @new_status = SUBSTRING(ERROR_MESSAGE(), 1, 150);
        -- Use correct column names in the AGRO_ERR_LOG table
        INSERT INTO TESTUSER.AGRO_ERR_LOG (Kaller, sqlerr)
        VALUES (@caller, @new_status);
        COMMIT;
    END CATCH;
END;
GO

-- Create the pAgroFaktProcedure procedure
CREATE PROCEDURE TESTUSER.pAgroFaktProcedure
    @new_status NVARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @caller NVARCHAR(150) = 'pAgroFakt';
    DECLARE @iID Numeric(26,0),@sDATO DATE, @sINST_CLOSE VARCHAR(26), @iINST_VOLUM FLOAT, @iINSTRUMENT FLOAT;

    BEGIN TRY
       BEGIN TRANSACTION;
        DELETE FROM TESTUSER.FAKT_AGRO;
        COMMIT;

        DECLARE c_AKER_AGRO CURSOR FOR
            SELECT ID, DATO, AKER_CLOSE, AKER_VOLUM, INSTRUMENT
            FROM TESTUSER.AKER_AGRO;

        OPEN c_AKER_AGRO;
        FETCH NEXT FROM c_AKER_AGRO INTO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC TESTUSER.Insert_FAKT_AGRO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT, @new_status OUTPUT, @caller;
            FETCH NEXT FROM c_AKER_AGRO INTO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT;
        END;

        CLOSE c_AKER_AGRO;
        DEALLOCATE c_AKER_AGRO;

        -- Repeat the same for FRO_AGRO and YARA_AGRO cursors

        DECLARE c_FRO_AGRO CURSOR FOR
            SELECT ID, DATO, FRO_CLOSE, FRO_VOLUM, INSTRUMENT
            FROM TESTUSER.FRO_AGRO;

        OPEN c_FRO_AGRO;
        FETCH NEXT FROM c_FRO_AGRO INTO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC TESTUSER.Insert_FAKT_AGRO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT, @new_status OUTPUT, @caller;
            FETCH NEXT FROM c_FRO_AGRO INTO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT;
        END;

        CLOSE c_FRO_AGRO;
        DEALLOCATE c_FRO_AGRO;

        DECLARE c_YARA_AGRO CURSOR FOR
            SELECT ID, DATO, YARA_CLOSE, YARA_VOLUM, INSTRUMENT
            FROM TESTUSER.YARA_AGRO;

        OPEN c_YARA_AGRO;
        FETCH NEXT FROM c_YARA_AGRO INTO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC TESTUSER.Insert_FAKT_AGRO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT, @new_status OUTPUT, @caller;
            FETCH NEXT FROM c_YARA_AGRO INTO @iID, @sDATO, @sINST_CLOSE, @iINST_VOLUM, @iINSTRUMENT;
        END;

        CLOSE c_YARA_AGRO;
        DEALLOCATE c_YARA_AGRO;

        DECLARE @sql NVARCHAR(MAX) = 'EXEC TESTUSER.AG_LOGGING$INSERT_AGRO_RUN_LOG @caller, @new_status';
        EXEC sp_executesql @sql, N'@caller NVARCHAR(150), @new_status NVARCHAR(255)', @caller, @new_status;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @new_status = SUBSTRING(ERROR_MESSAGE(), 1, 150);
        -- Use correct column names in the AGRO_ERR_LOG table
        INSERT INTO TESTUSER.AGRO_ERR_LOG (Kaller, sqlerr)
        VALUES (@caller, @new_status);
        RAISERROR ('Noe gikk galt', 16, 1);
    END CATCH;
END;
GO

-- Create the pAgroFaktAggTotProcedure procedure
CREATE PROCEDURE TESTUSER.pAgroFaktAggTotProcedure
    @new_status NVARCHAR(255) OUTPUT
AS
BEGIN
    DECLARE @caller NVARCHAR(150) = 'pAgroFaktAggTot';
    DECLARE @iINSTRUMENT_agg FLOAT, @sNAVN NVARCHAR(255), @sADRESSE NVARCHAR(255), @sMERKNAD NVARCHAR(255);
    DECLARE @iVOLUM_agg FLOAT, @l_navn NVARCHAR(255);

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM TESTUSER.FAKT_AGRO_AGG_TOT;
        COMMIT;

        DECLARE c_INSTRUMENT_AGRO CURSOR FOR
            SELECT INSTRUMENT, NAVN, ADRESSE, MERKNAD
            FROM TESTUSER.instrument_agro;

        OPEN c_INSTRUMENT_AGRO;
        FETCH NEXT FROM c_INSTRUMENT_AGRO INTO @iINSTRUMENT_agg, @sNAVN, @sADRESSE, @sMERKNAD;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @iVOLUM_agg = SUM(inst_volum)
            FROM TESTUSER.FAKT_AGRO
            WHERE instrument = @iINSTRUMENT_agg;

            IF @iINSTRUMENT_agg = 1
                SET @l_navn = @sNAVN + ',' + @sADRESSE + ',' + @sMERKNAD;
            ELSE IF @iINSTRUMENT_agg = 2
                SET @l_navn = @sNAVN + ';' + @sADRESSE + ';' + @sMERKNAD;
            ELSE
                SET @l_navn = @sNAVN + '*' + @sADRESSE + '*' + @sMERKNAD;

            EXEC TESTUSER.Insert_FAKT_AGRO_AGG_TOT @iINSTRUMENT_agg, @l_navn, @iVOLUM_agg, @new_status OUTPUT, @caller;

            FETCH NEXT FROM c_INSTRUMENT_AGRO INTO @iINSTRUMENT_agg, @sNAVN, @sADRESSE, @sMERKNAD;
        END;

        CLOSE c_INSTRUMENT_AGRO;
        DEALLOCATE c_INSTRUMENT_AGRO;

        DECLARE @sql NVARCHAR(MAX) = 'EXEC TESTUSER.AG_LOGGING$INSERT_AGRO_RUN_LOG @caller, @new_status';
        EXEC sp_executesql @sql, N'@caller NVARCHAR(150), @new_status NVARCHAR(255)', @caller, @new_status;
       COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        SET @new_status = SUBSTRING(ERROR_MESSAGE(), 1, 150);
        -- Use correct column names in the AGRO_ERR_LOG table
        INSERT INTO TESTUSER.AGRO_ERR_LOG (Kaller, sqlerr)
        VALUES (@caller, @new_status);
        RAISERROR ('Noe gikk galt', 16, 1);
    END CATCH;
END;
GO

-- Create the pAgroFakt procedure
CREATE PROCEDURE TESTUSER.pAgroFakt
AS
BEGIN
    DECLARE @new_status NVARCHAR(255);
    EXEC TESTUSER.pAgroFaktProcedure @new_status OUTPUT;
END;
GO

-- Create the pAgroFaktAggTot procedure
CREATE PROCEDURE TESTUSER.pAgroFaktAggTot
AS
BEGIN
    DECLARE @new_status NVARCHAR(255);
    EXEC TESTUSER.pAgroFaktAggTotProcedure @new_status OUTPUT;
END;
GO