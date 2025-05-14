CREATE EXTENSION IF NOT EXISTS pgfsm;

-- Insert FSM definition of turnstile.
INSERT INTO transition (name, from_state, transition, to_state)
    VALUES
    ('turnstile', 'locked', 'coin', 'unlocked'),
    ('turnstile', 'unlocked', 'push', 'locked');

-- Insert FSM definition for door.
INSERT INTO transition (name, from_state, transition, to_state)
    VALUES
    ('door', 'opened', 'close', 'closing'),
    ('door', 'closed', 'open', 'opening'),
    ('door', 'opening', 'is_opened', 'opened'),
    ('door', 'closing', 'is_closed', 'closed');

-- insert or update on table "machine" violates foreign key constraint "machine_name_fkey"
INSERT INTO machine (name, state)
    VALUES
    ('turnstile', 'bar');

-- insert or update on table "machine" violates foreign key constraint "machine_name_fkey"
INSERT INTO machine (name, state)
    VALUES
    ('fork', 'opened');

-- Insert some machines in some valid states.
INSERT INTO machine (id, name, state)
    VALUES
    (1, 'door', 'opened'),
    (2, 'door', 'closed'),
    (3, 'turnstile', 'locked'),
    (4, 'turnstile', 'unlocked');

-- door 1 closing
UPDATE machine SET state = 'closing' WHERE id = 1;

--  door 1 closed
UPDATE machine SET state = 'closed' WHERE id = 1;

-- door 1 cant go from closed to closing
UPDATE machine SET state = 'closing' WHERE id = 2;

-- Door 2 goes from closed to opening
SELECT * FROM do_transition(2, 'open');
select state = 'opening' FROM machine WHERE id = 2;

-- Door 2 can go from opening to opened
SELECT * FROM do_transition(2, 'is_opened');

select state = 'opened' FROM machine WHERE id = 2;

-- Door 2 cant go from opened to opening
SELECT * FROM do_transition(2, 'is_opened');

select state = 'opened' FROM machine WHERE id = 2;
