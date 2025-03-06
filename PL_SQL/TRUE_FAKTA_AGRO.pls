CREATE OR REPLACE PACKAGE         "TRUE_FAKTA_AGRO" AS
/******************************************************************************
   NAME:       TRUE_FAKTA_AGRO
   PURPOSE:  Tabellen Fakt_agro fylles med data fra tabellene Aker_agro, fro_agro, yara_agro

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        1.2.2025             1. Created this package.
   rekkefølge:

   1. kjør pAgroFakt..: Fyller tabellen FAKT_AGRO
   2. kjør pAgroFaktAggTot..: Fyller FAKT_AGRO_AGG_TOT


******************************************************************************/

  PROCEDURE pAgroFakt 			(new_status out VARCHAR2);
  PROCEDURE pAgroFaktAggTot		(new_status out VARCHAR2);


END TRUE_FAKTA_AGRO;
/


CREATE OR REPLACE PACKAGE BODY TRUE_FAKTA_AGRO AS
/******************************************************************************
   NAME:       na
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        01.2.2025   Einar             1. Created this package body.

******************************************************************************/

caller              VARCHAR(20);
PROCEDURE Insert_FAKT_AGRO( iID           	ADMIN.FAKT_AGRO.ID%TYPE,
                            sDATO  			ADMIN.FAKT_AGRO.DATO%TYPE,
                            sINST_CLOSE     ADMIN.FAKT_AGRO.INST_CLOSE%TYPE,
							iINST_VOLUM		ADMIN.FAKT_AGRO.INST_VOLUM%TYPE,
							iINSTRUMENT		ADMIN.FAKT_AGRO.INSTRUMENT%TYPE,
                            new_status      out VARCHAR2,
                            caller          VARCHAR2)   
IS
BEGIN

   INSERT INTO FAKT_AGRO VALUES (iID,
                                 sDATO,
                                 sINST_CLOSE,
								 iINST_VOLUM,
								 iINSTRUMENT);
   commit;                                
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
              new_status := SUBSTR(SQLERRM,1,150);
              INSERT INTO AGRO_ERR_LOG VALUES ( caller,new_status, iID,to_char(iINSTRUMENT));
              commit;
end Insert_FAKT_AGRO; 

PROCEDURE Insert_FAKT_AGRO_AGG_TOT( iINSTRUMENT		ADMIN.FAKT_AGRO_AGG_TOT.INSTRUMENT%TYPE,
									sNAVN  			ADMIN.FAKT_AGRO_AGG_TOT.NAVN%TYPE,
									iVOLUM			ADMIN.FAKT_AGRO_AGG_TOT.VOLUM%TYPE,
									new_status      out VARCHAR2,
									caller          VARCHAR2)   
IS
BEGIN

   INSERT INTO FAKT_AGRO_AGG_TOT VALUES (iINSTRUMENT,
                                 sNAVN,
                                 iVOLUM);
   commit;                                
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
              new_status := SUBSTR(SQLERRM,1,150);
              INSERT INTO AGRO_ERR_LOG VALUES ( caller,new_status, iINSTRUMENT,sNAVN);
              commit;
end Insert_FAKT_AGRO_AGG_TOT; 

PROCEDURE pAgroFaktAggTot(new_status out VARCHAR2) 
  IS 
-- l var INSTRUMENT_AGRO
	iINSTRUMENT		ADMIN.INSTRUMENT_AGRO.INSTRUMENT%TYPE;
	sNAVN           ADMIN.INSTRUMENT_AGRO.NAVN%TYPE;
	sADRESSE 		ADMIN.INSTRUMENT_AGRO.ADRESSE%TYPE;
	sMERKNAD  		ADMIN.INSTRUMENT_AGRO.MERKNAD%TYPE;

-- l var FAKT_AGRO_AGG_TOT	
	iINSTRUMENT_agg	ADMIN.FAKT_AGRO_AGG_TOT.INSTRUMENT%TYPE;
	sNAVN_agg		ADMIN.FAKT_AGRO_AGG_TOT.NAVN%TYPE;
	iVOLUM_agg		ADMIN.FAKT_AGRO_AGG_TOT.VOLUM%TYPE;

	l_navn			ADMIN.INSTRUMENT_AGRO.NAVN%TYPE;

   CURSOR c_INSTRUMENT_AGRO IS          
    SELECT 	IA.INSTRUMENT,
			IA.NAVN, 
			IA.ADRESSE,
			IA.MERKNAD
    FROM instrument_agro IA;

   CURSOR c_FAKT_AGRO_AGG_TOT IS          
	SELECT SUM(inst_volum) AS volum 
	FROM FAKT_AGRO
		WHERE instrument = iINSTRUMENT_agg;


 Begin

 caller := 'pAgroFaktAggTot';

 --
 --  sletter fra FAKT_AGRO_AGG_TOT
 --
 delete from FAKT_AGRO_AGG_TOT;
 commit;

  open c_INSTRUMENT_AGRO;
	 loop
	  fetch c_INSTRUMENT_AGRO into iINSTRUMENT_agg,						
							sNAVN,
							sADRESSE,
							sMERKNAD;
	  exit when c_INSTRUMENT_AGRO%notfound;
		open c_FAKT_AGRO_AGG_TOT;
			fetch c_FAKT_AGRO_AGG_TOT into iVOLUM_agg;
		close c_FAKT_AGRO_AGG_TOT;

             if    iINSTRUMENT_agg = 1 then
                select  sNAVN || ',' || sADRESSE  || ',' || sMERKNAD into l_navn from dual;
             elsif iINSTRUMENT_agg = 2 then                 
                select  sNAVN || ';' || sADRESSE  || ';' || sMERKNAD into l_navn from dual;
             else 
                select  sNAVN || '*' || sADRESSE  || '*' || sMERKNAD into l_navn from dual;  
             end if;  		

			Insert_FAKT_AGRO_AGG_TOT( 	iINSTRUMENT_agg,
										l_navn,
										iVOLUM_agg,
										new_status,
										caller);

	 end loop;
 close c_INSTRUMENT_AGRO;



 AG_LOGGING.INSERT_AGRO_RUN_LOG (caller, new_status );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
            new_status := SUBSTR(SQLERRM,1,150);
            INSERT INTO AGRO_ERR_LOG VALUES ( caller, new_status, iINSTRUMENT_agg,sNAVN);
            raise_application_error (-20003, 'Noe gikk galt' );
            RAISE;
        commit;

 END pAgroFaktAggTot; 

PROCEDURE pAgroFakt(new_status out VARCHAR2) 
  IS 

	iID           	ADMIN.FAKT_AGRO.ID%TYPE;
	sDATO  			ADMIN.FAKT_AGRO.DATO%TYPE;
	sINST_CLOSE     ADMIN.FAKT_AGRO.INST_CLOSE%TYPE;
	iINST_VOLUM		ADMIN.FAKT_AGRO.INST_VOLUM%TYPE;
	iINSTRUMENT		ADMIN.FAKT_AGRO.INSTRUMENT%TYPE;

   CURSOR c_AKER_AGRO IS          
    SELECT AA.ID, AA.DATO, AA.AKER_CLOSE, AA.AKER_VOLUM, AA.INSTRUMENT
    FROM AKER_AGRO AA;

   CURSOR c_FRO_AGRO IS          
    SELECT FA.ID, FA.DATO, FA.FRO_CLOSE, FA.FRO_VOLUM, FA.INSTRUMENT
    FROM FRO_AGRO FA;

   CURSOR c_YARA_AGRO IS          
    SELECT YA.ID, YA.DATO, YA.YARA_CLOSE, YA.YARA_VOLUM, YA.INSTRUMENT
    FROM YARA_AGRO YA;


 Begin

 caller := 'pAgroFakt';

 --
 --  sletter fra FAKT_AGRO
 --
 delete from FAKT_AGRO;
 commit;


 -- select to_number(to_char(sysdate,'yyyymmdd'),'99999999') into sDATO from dual;


 -- AKER_AGRO

 open c_AKER_AGRO;
	 loop
	  fetch c_AKER_AGRO into iID,						
							sDATO,
							sINST_CLOSE,
							iINST_VOLUM,
							iINSTRUMENT;
	  exit when c_AKER_AGRO%notfound;

		Insert_FAKT_AGRO( 	iID,
							sDATO,
							sINST_CLOSE,
							iINST_VOLUM,
							iINSTRUMENT,
							new_status,
							caller)   ;

	 end loop;
 close c_AKER_AGRO;

 -- FRO_AGRO

 open c_FRO_AGRO;
	 loop
	  fetch c_FRO_AGRO into iID,						
							sDATO,
							sINST_CLOSE,
							iINST_VOLUM,
							iINSTRUMENT;
	  exit when c_FRO_AGRO%notfound;

		Insert_FAKT_AGRO( 	iID,
							sDATO,
							sINST_CLOSE,
							iINST_VOLUM,
							iINSTRUMENT,
							new_status,
							caller)   ;

	 end loop;
 close c_FRO_AGRO;

 -- YARA_AGRO

 open c_YARA_AGRO;
	 loop
	  fetch c_YARA_AGRO into iID,						
							sDATO,
							sINST_CLOSE,
							iINST_VOLUM,
							iINSTRUMENT;
	  exit when c_YARA_AGRO%notfound;

		Insert_FAKT_AGRO( 	iID,
							sDATO,
							sINST_CLOSE,
							iINST_VOLUM,
							iINSTRUMENT,
							new_status,
							caller)   ;

	 end loop;
 close c_YARA_AGRO;


 AG_LOGGING.INSERT_AGRO_RUN_LOG (caller, new_status );

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
            new_status := SUBSTR(SQLERRM,1,150);
            INSERT INTO AGRO_ERR_LOG VALUES ( caller, new_status, iID,to_char(iINSTRUMENT));
            raise_application_error (-20003, 'Noe gikk galt' );
            RAISE;
        commit;

 END pAgroFakt;



END TRUE_FAKTA_AGRO;
/
