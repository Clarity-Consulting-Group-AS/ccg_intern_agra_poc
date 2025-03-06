CREATE OR REPLACE PACKAGE AG_LOGGING AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
    PROCEDURE INSERT_AGRO_RUN_LOG (l_KALLER IN varchar2,
                                new_status out VARCHAR2); 
END AG_LOGGING;

/


CREATE OR REPLACE PACKAGE BODY AG_LOGGING AS
sqlerr              VARCHAR(150);

PROCEDURE INSERT_AGRO_RUN_LOG       (  l_KALLER                            VARCHAR2,
                                        new_status                      out VARCHAR2)

IS

l_KJORE_TID varchar(150);
l_KJORE_DAG NUMBER;
BEGIN

    select to_char(sysdate, 'HH24:MI:SS') into l_KJORE_TID from dual; 

    select to_char(sysdate, 'YYYYMMDD' ) into l_KJORE_DAG from dual;     


    INSERT INTO AGRO_RUN_LOG VALUES (  l_KALLER, 
                                        l_KJORE_DAG, 
                                        l_KJORE_TID ); 
   commit;  
   new_status := 'ok';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       Null;
     WHEN OTHERS THEN
              new_status := 'Nok';
              sqlerr := SUBSTR(SQLERRM,1,150);
              INSERT INTO AGRO_ERR_LOG VALUES ( l_KALLER,sqlerr, l_KJORE_TID, l_KJORE_TID);
              commit;
end INSERT_AGRO_RUN_LOG; 

END AG_LOGGING;
/
