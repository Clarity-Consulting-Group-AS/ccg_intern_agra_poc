-- filepath: untitled://untitled/Untitled-35
CREATE OR REPLACE PROCEDURE reverse_string (
    p_string IN NVARCHAR2,
    result OUT NVARCHAR2
) AS
    v_result NVARCHAR2(4000) := '';
    v_len NUMBER := LENGTH(p_string);
    v_i NUMBER := 1;
BEGIN
    -- Loop to reverse the string
    WHILE v_i <= v_len LOOP
        v_result := SUBSTR(p_string, v_i, 1) || v_result;
        v_i := v_i + 1;
    END LOOP;

    result := v_result;
END;
/