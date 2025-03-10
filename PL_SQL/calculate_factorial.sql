-- filepath: untitled:Untitled-1
CREATE OR REPLACE PROCEDURE calculate_factorial (
    p_number IN NUMBER,
    p_result OUT NUMBER
) AS
    v_counter NUMBER := 1;
BEGIN
    p_result := 1;

    -- Loop to calculate factorial
    WHILE v_counter <= p_number LOOP
        p_result := p_result * v_counter;
        v_counter := v_counter + 1;
    END LOOP;
END;
/