create or replace PROCEDURE find_pairs_with_sum(v_target_sum IN NUMBER) IS
    TYPE t_num_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_numbers t_num_array;
    v_i PLS_INTEGER;
    v_j PLS_INTEGER;
BEGIN
    -- Initialize the array
    v_numbers(1) := 1;
    v_numbers(2) := 2;
    v_numbers(3) := 3;
    v_numbers(4) := 4;
    v_numbers(5) := 5;
    v_numbers(6) := 6;
    v_numbers(7) := 7;
    v_numbers(8) := 8;
    v_numbers(9) := 9;
    v_numbers(10) := 10;

    -- Find unique pairs of numbers whose sum is equal to v_target_sum
    FOR v_i IN 1..v_numbers.COUNT LOOP
        FOR v_j IN v_i+1..v_numbers.COUNT LOOP
            IF v_numbers(v_i) + v_numbers(v_j) = v_target_sum THEN
                DBMS_OUTPUT.PUT_LINE('Pair found: ' || v_numbers(v_i) || ', ' || v_numbers(v_j));
            END IF;
        END LOOP;
    END LOOP;
END;
