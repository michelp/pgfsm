BEGIN;
SELECT plan(5);

select lives_ok($$
INSERT INTO fsm.transition (name, from_state, transition, to_state)
    VALUES
    ('turnstile', 'locked', 'coin', 'unlocked'),
    ('turnstile', 'unlocked', 'push', 'locked');
    $$,
    'Insert FSM definition of turnstile.');


select lives_ok($$
INSERT INTO fsm.transition (name, from_state, transition, to_state)
    VALUES
    ('door', 'opened', 'close', 'closing'),
    ('door', 'closed', 'open', 'opening'),
    ('door', 'opening', 'is_opened', 'opened'),
    ('door', 'closing', 'is_closed', 'closed');
    $$,
    'Insert FSM definition for door.');


select lives_ok($$
INSERT into fsm.machine (name, state)
    VALUES
    ('door', 'opened'),
    ('door', 'closed'),
    ('turnstile', 'locked'),
    ('turnstile', 'unlocked');
    $$,
    'Insert some machines in some valid states.');


select throws_ok($$
INSERT into fsm.machine (name, state)
    VALUES
    ('turnstile', 'bar');
    $$,
    'P0001',
    'Invalid initial state bar');


select throws_ok($$
INSERT into fsm.machine (name, state)
    VALUES
    ('fork', 'opened');
    $$,
    'P0001',
    'Invalid FSM name fork');


SELECT * from finish();
ROLLBACK;
