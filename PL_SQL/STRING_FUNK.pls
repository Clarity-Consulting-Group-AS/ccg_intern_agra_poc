CREATE OR REPLACE PACKAGE STRING_FUNK
IS

TYPE t_array IS TABLE OF VARCHAR2(3900)
   INDEX BY BINARY_INTEGER;

FUNCTION LAG_ARRAY (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array;

END;

/


CREATE OR REPLACE PACKAGE BODY STRING_FUNK
IS

   FUNCTION LAG_ARRAY (p_in_string VARCHAR2, p_delim VARCHAR2) RETURN t_array
   IS
 
      i       number :=0;
      pos     number :=0;
      lv_str  varchar2(4000) := p_in_string;

   strings t_array;

   BEGIN

      -- Finner posisjonen til første forekomst
      pos := instr(lv_str,p_delim,1,1);
      IF pos = 0 THEN
          strings(1) := lv_str;
      END IF ;

      -- looper så lenge det finnes flere
      WHILE ( pos != 0) LOOP

         -- øker teller
         i := i + 1;

         -- lager array av strenger
         strings(i) := substr(lv_str,1,pos-1);

         -- Sjalter ut behandlet forekomst
         lv_str := substr(lv_str,pos+1,length(lv_str));

         -- Finner posisjonen til neste forekomst
         pos := instr(lv_str,p_delim,1,1);

         -- Ingen flere? setter inn siste element.
         IF pos = 0 THEN

            strings(i+1) := lv_str;

         END IF;
          dbms_output.put_line('Test i loop '|| strings(i));
      END LOOP;
      dbms_output.put_line('Test = '|| strings(i));

      RETURN strings;

   END LAG_ARRAY;


END;

/
