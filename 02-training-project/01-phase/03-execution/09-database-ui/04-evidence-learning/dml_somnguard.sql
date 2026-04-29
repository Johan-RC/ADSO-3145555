-- DML de ejemplo para SomnGuard 3FN
-- PostgreSQL

INSERT INTO status_catalog (id, code, name, description) VALUES
('11111111-1111-1111-1111-111111111111', 'ACTIVE', 'Activo', 'Registro habilitado'),
('22222222-2222-2222-2222-222222222222', 'INACTIVE', 'Inactivo', 'Registro deshabilitado'),
('33333333-3333-3333-3333-333333333333', 'DELETED', 'Eliminado', 'Registro dado de baja');

INSERT INTO media_type_catalog (id, code, name) VALUES
('44444444-4444-4444-4444-444444444444', 'IMAGE', 'Imagen');



INSERT INTO severity_catalog (id, code, name, rank) VALUES
('77777777-7777-7777-7777-777777777777', 'LOW', 'Baja', 1),
('88888888-8888-8888-8888-888888888888', 'MEDIUM', 'Media', 2),
('99999999-9999-9999-9999-999999999999', 'HIGH', 'Alta', 3),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'CRITICAL', 'Crítica', 4);

INSERT INTO event_category_catalog (id, code, name) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'ALERT', 'Alerta'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'STATUS', 'Estado'),
('dddddddd-dddd-dddd-dddd-dddddddddddd', 'DIAGNOSTIC', 'Diagnóstico');

INSERT INTO role (id, name, description, status_id) VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'ADMIN', 'Administrador del sistema', '11111111-1111-1111-1111-111111111111'),
('ffffffff-ffff-ffff-ffff-ffffffffffff', 'USER', 'Usuario estándar', '11111111-1111-1111-1111-111111111111');

INSERT INTO permission (id, name, status_id) VALUES
('12121212-1212-1212-1212-121212121212', 'MANAGE_DEVICES', '11111111-1111-1111-1111-111111111111'),
('34343434-3434-3434-3434-343434343434', 'VIEW_EVENTS', '11111111-1111-1111-1111-111111111111');

INSERT INTO module (id, name, status_id) VALUES
('56565656-5656-5656-5656-565656565656', 'Security', '11111111-1111-1111-1111-111111111111'),
('78787878-7878-7878-7878-787878787878', 'Monitoring', '11111111-1111-1111-1111-111111111111');

INSERT INTO form (id, name, status_id) VALUES
('90909090-9090-9090-9090-909090909090', 'DeviceForm', '11111111-1111-1111-1111-111111111111'),
('abababab-abab-abab-abab-abababababab', 'EventForm', '11111111-1111-1111-1111-111111111111');

INSERT INTO form_module (id, module_id, form_id, status_id) VALUES
('cdcdcdcd-cdcd-cdcd-cdcd-cdcdcdcdcdcd', '56565656-5656-5656-5656-565656565656', '90909090-9090-9090-9090-909090909090', '11111111-1111-1111-1111-111111111111'),
('efefefef-efef-efef-efef-efefefefefef', '78787878-7878-7878-7878-787878787878', 'abababab-abab-abab-abab-abababababab', '11111111-1111-1111-1111-111111111111');

INSERT INTO sound_pattern (id, code, description, frequency_hz, duration, status_id) VALUES
('10101010-1010-1010-1010-101010101010', 'SP-LOW', 'Patrón suave', 440, 3, '11111111-1111-1111-1111-111111111111'),
('20202020-2020-2020-2020-202020202020', 'SP-HIGH', 'Patrón crítico', 880, 5, '11111111-1111-1111-1111-111111111111');

INSERT INTO event_type (id, code, name, category_id, default_severity_id, default_sound_pattern_id, status_id) VALUES
('30303030-3030-3030-3030-303030303030', 'BED_EXIT', 'Salida de cama', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '99999999-9999-9999-9999-999999999999', '20202020-2020-2020-2020-202020202020', '11111111-1111-1111-1111-111111111111'),
('40404040-4040-4040-4040-404040404040', 'MOVEMENT', 'Movimiento', 'dddddddd-dddd-dddd-dddd-dddddddddddd', '77777777-7777-7777-7777-777777777777', '10101010-1010-1010-1010-101010101010', '11111111-1111-1111-1111-111111111111');

INSERT INTO person (id, first_name, last_name, phone, status_id) VALUES
('51515151-5151-5151-5151-515151515151', 'Ana', 'Paredes', '+34 600 111 222', '11111111-1111-1111-1111-111111111111'),
('61616161-6161-6161-6161-616161616161', 'Luis', 'Gomez', '+34 600 333 444', '11111111-1111-1111-1111-111111111111');

INSERT INTO "user" (id, person_id, email, password, status_id) VALUES
('71717171-7171-7171-7171-717171717171', '51515151-5151-5151-5151-515151515151', 'ana@somnguard.com', 'hash_ana', '11111111-1111-1111-1111-111111111111'),
('81818181-8181-8181-8181-818181818181', '61616161-6161-6161-6161-616161616161', 'luis@somnguard.com', 'hash_luis', '11111111-1111-1111-1111-111111111111');

INSERT INTO role_user (id, user_id, role_id, status_id) VALUES
('92929292-9292-9292-9292-929292929292', '71717171-7171-7171-7171-717171717171', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111'),
('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', '81818181-8181-8181-8181-818181818181', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '11111111-1111-1111-1111-111111111111');

INSERT INTO role_form_permission (id, role_id, permission_id, form_id, status_id) VALUES
('b1b1b1b1-b1b1-b1b1-b1b1-b1b1b1b1b1b1', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '12121212-1212-1212-1212-121212121212', '90909090-9090-9090-9090-909090909090', '11111111-1111-1111-1111-111111111111'),
('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1', 'ffffffff-ffff-ffff-ffff-ffffffffffff', '34343434-3434-3434-3434-343434343434', 'abababab-abab-abab-abab-abababababab', '11111111-1111-1111-1111-111111111111');

INSERT INTO device (id, serial_number, api_key_hash, firmware_version, status_id) VALUES
('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', 'SG-DEV-0001', 'api_hash_001', '1.0.0', '11111111-1111-1111-1111-111111111111');

INSERT INTO device_assignment (id, device_id, user_id, assigned_at, unassigned_at, status_id) VALUES
('e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1', 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', '71717171-7171-7171-7171-717171717171', '2026-04-28 08:00:00+00', NULL, '11111111-1111-1111-1111-111111111111');

INSERT INTO device_config (id, device_id, config_data, status_id) VALUES
('f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1', 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', '{"volume": 80, "night_mode": true}', '11111111-1111-1111-1111-111111111111');

INSERT INTO event (id, device_id, event_type_id, occurred_at, is_offline_sync, status_id) VALUES
('11112222-3333-4444-5555-666677778888', 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', '30303030-3030-3030-3030-303030303030', '2026-04-28 09:10:00+00', FALSE, '11111111-1111-1111-1111-111111111111'),
('99990000-aaaa-bbbb-cccc-ddddeeeeffff', 'd1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1', '40404040-4040-4040-4040-404040404040', '2026-04-28 09:20:00+00', TRUE, '11111111-1111-1111-1111-111111111111');

INSERT INTO alert (id, event_id, sound_pattern_id, status_id) VALUES
('12120000-1212-1212-1212-121212121212', '11112222-3333-4444-5555-666677778888', '20202020-2020-2020-2020-202020202020', '11111111-1111-1111-1111-111111111111');

INSERT INTO evidence (id, event_id, media_type_id, file_url, status_id) VALUES
('34340000-3434-3434-3434-343434343434', '11112222-3333-4444-5555-666677778888', '44444444-4444-4444-4444-444444444444', 'https://cdn.somnguard.local/evidence/bed_exit_001.jpg', '11111111-1111-1111-1111-111111111111');

INSERT INTO notification (id, user_id, event_id, title, message, status_id) VALUES
('56560000-5656-5656-5656-565656565656', '71717171-7171-7171-7171-717171717171', '11112222-3333-4444-5555-666677778888', 'Alerta de salida de cama', 'Se detectó una salida de cama en el dispositivo SG-DEV-0001.', '11111111-1111-1111-1111-111111111111');
