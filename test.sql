BEGIN;
SELECT plan(14);

SELECT lives_ok($$
INSERT INTO fsm.transition (name, from_state, transition, to_state)
    VALUES
    ('turnstile', 'locked', 'coin', 'unlocked'),
    ('turnstile', 'unlocked', 'push', 'locked');
    $$,
    'Insert FSM definition of turnstile.');


SELECT lives_ok($$
INSERT INTO fsm.transition (name, from_state, transition, to_state)
    VALUES
    ('door', 'opened', 'close', 'closing'),
    ('door', 'closed', 'open', 'opening'),
    ('door', 'opening', 'is_opened', 'opened'),
    ('door', 'closing', 'is_closed', 'closed');
    $$,
    'Insert FSM definition for door.');


SELECT throws_ok($$
INSERT INTO fsm.machine (name, state)
    VALUES
    ('turnstile', 'bar');
    $$,
    '23503',
    'insert or update on table "machine" violates foreign key constraint "machine_name_fkey"');


SELECT throws_ok($$
INSERT INTO fsm.machine (name, state)
    VALUES
    ('fork', 'opened');
    $$,
    '23503',
    'insert or update on table "machine" violates foreign key constraint "machine_name_fkey"');


SELECT lives_ok($$
INSERT INTO fsm.machine (id, name, state)
    VALUES
    (1, 'door', 'opened'),
    (2, 'door', 'closed'),
    (3, 'turnstile', 'locked'),
    (4, 'turnstile', 'unlocked');
    $$,
    'Insert some machines in some valid states.');


SELECT lives_ok($$
    UPDATE fsm.machine SET state = 'closing' WHERE id = 1;$$,
    'door 1 closing');


SELECT lives_ok($$
    UPDATE fsm.machine SET state = 'closed' WHERE id = 1;$$,
    'door 1 closed');


SELECT throws_ok($$
    UPDATE fsm.machine SET state = 'closing' WHERE id = 2;$$,
    'P0001',
    'Invalid transition closing',
    'door 1 cant go from closed to closing');


SELECT lives_ok($$
    SELECT * FROM fsm.do_transition(2, 'open');$$,
    'Door 2 can go from closed to opening');


select is(state, 'opening') FROM fsm.machine WHERE id = 2;


select lives_ok($$
    SELECT * FROM fsm.do_transition(2, 'is_opened');$$,
    'Door 2 can go from opening to opened');


select is(state, 'opened') FROM fsm.machine WHERE id = 2;


select throws_ok($$
    SELECT * FROM fsm.do_transition(2, 'is_opened');$$,
    'P0001',
    'No valid transition for 2 named is_opened',
    'Door 2 cant go from opened to opening');


select is(state, 'opened') FROM fsm.machine WHERE id = 2;


SELECT * from finish();
ROLLBACK;
