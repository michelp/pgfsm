BEGIN;
SELECT plan(4);

select lives_ok($$
INSERT INTO fsm.transition (name, from_state, transition, to_state)
    VALUES
    ('turnstile', 'locked', 'coin', 'unlocked'),
    ('turnstile', 'locked', 'push', 'locked'),
    ('turnstile', 'unlocked', 'push', 'locked'),
    ('turnstile', 'unlocked', 'coin', 'unlocked');$$,
    'turnstile');


select lives_ok($$
INSERT INTO fsm.transition (name, from_state, transition, to_state)
    VALUES
    ('door', 'opened', 'close', 'closing'),
    ('door', 'closed', 'open', 'opening'),
    ('door', 'opening', 'is_opened', 'opened'),
    ('door', 'closing', 'is_closed', 'closed'),
    ('door', 'opening', 'close', 'closing'),
    ('door', 'closing', 'open', 'opening');$$,
    'door');


select lives_ok($$
INSERT into fsm.machine (name, state)
    VALUES
    ('door', 'opened'),
    ('door', 'closed'),
    ('turnstile', 'locked'),
    ('turnstile', 'unlocked');$$,
    'machine');

select throws_ok($$
INSERT into fsm.machine (name, state)
    VALUES
    ('turnstile', 'bar');$$,
    'P0001',
    'Invalid initial state bar');

SELECT * from finish();
ROLLBACK;
