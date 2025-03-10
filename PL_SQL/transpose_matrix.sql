CREATE OR REPLACE PROCEDURE transpose_matrix IS
    TYPE t_matrix IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_matrix t_matrix;
    v_transposed_matrix t_matrix;
    v_size PLS_INTEGER := 3;
    v_i PLS_INTEGER;
    v_j PLS_INTEGER;
BEGIN
    -- Initialize the matrix
    FOR v_i IN 1..v_size LOOP
        FOR v_j IN 1..v_size LOOP
            v_matrix((v_i-1)*v_size + v_j) := (v_i-1)*v_size + v_j;
        END LOOP;
    END LOOP;

    -- Transpose the matrix
    FOR v_i IN 1..v_size LOOP
        FOR v_j IN 1..v_size LOOP
            v_transposed_matrix((v_j-1)*v_size + v_i) := v_matrix((v_i-1)*v_size + v_j);
        END LOOP;
    END LOOP;

    -- Print the transposed matrix
    FOR v_i IN 1..v_size LOOP
        FOR v_j IN 1..v_size LOOP
            DBMS_OUTPUT.PUT_LINE('Element (' || v_i || ', ' || v_j || '): ' || v_transposed_matrix((v_i-1)*v_size + v_j));
        END LOOP;
    END LOOP;
END;
/