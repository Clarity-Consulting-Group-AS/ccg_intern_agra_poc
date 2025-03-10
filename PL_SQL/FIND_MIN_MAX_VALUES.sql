create or replace PROCEDURE find_min_max_values (
    v_size IN PLS_INTEGER,
    v_max OUT NUMBER,
    v_min OUT NUMBER
) AS
    TYPE t_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_2d_array t_array;
    v_i PLS_INTEGER;
    v_j PLS_INTEGER;
BEGIN
    v_max := -999999;
    v_min := 999999;

    -- Initialize the 2D array
    FOR v_i IN 1..v_size LOOP
        FOR v_j IN 1..v_size LOOP
            v_2d_array((v_i-1)*v_size + v_j) := DBMS_RANDOM.VALUE(1, 100);
        END LOOP;
    END LOOP;

    -- Find the maximum and minimum values
    FOR v_i IN 1..v_size LOOP
        FOR v_j IN 1..v_size LOOP
            IF v_2d_array((v_i-1)*v_size + v_j) > v_max THEN
                v_max := v_2d_array((v_i-1)*v_size + v_j);
            END IF;
            IF v_2d_array((v_i-1)*v_size + v_j) < v_min THEN
                v_min := v_2d_array((v_i-1)*v_size + v_j);
            END IF;
        END LOOP;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Maximum value: ' || v_max);
    DBMS_OUTPUT.PUT_LINE('Minimum value: ' || v_min);
END;
