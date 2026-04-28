DO $$
DECLARE
    v_user_account_id uuid;
    v_security_role_id uuid;
    v_assigned_by_user_id uuid;
BEGIN
    SELECT ua.user_account_id
    INTO v_user_account_id
    FROM user_account ua
    ORDER BY ua.created_at
    LIMIT 1;

    SELECT ua.user_account_id
    INTO v_assigned_by_user_id
    FROM user_account ua
    ORDER BY ua.created_at
    LIMIT 1;

    SELECT sr.security_role_id
    INTO v_security_role_id
    FROM security_role sr
    LEFT JOIN user_role ur
        ON ur.security_role_id = sr.security_role_id
       AND ur.user_account_id = v_user_account_id
    WHERE ur.user_role_id IS NULL
    ORDER BY sr.created_at
    LIMIT 1;

    IF v_user_account_id IS NULL THEN
        RAISE EXCEPTION 'No existe user_account disponible.';
    END IF;

    IF v_security_role_id IS NULL THEN
        RAISE EXCEPTION 'No existe security_role disponible para asignar al usuario seleccionado.';
    END IF;

    CALL sp_assign_user_role(
        v_user_account_id,
        v_security_role_id,
        v_assigned_by_user_id
    );
END;
$$;

SELECT
    ua.username,
    ua.updated_at,
    sr.role_name,
    ur.assigned_at
FROM user_role ur
INNER JOIN user_account ua
    ON ua.user_account_id = ur.user_account_id
INNER JOIN security_role sr
    ON sr.security_role_id = ur.security_role_id
ORDER BY ur.created_at DESC
LIMIT 5;
