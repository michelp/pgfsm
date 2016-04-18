BEGIN;
DROP SCHEMA IF EXISTS fsm CASCADE;
CREATE SCHEMA fsm;



CREATE TABLE fsm.transition (
    name text NOT NULL,
    from_state text NOT NULL,
    transition text,
    to_state text,
    PRIMARY KEY (name, from_state)
);


CREATE TABLE fsm.machine (
    id BIGSERIAL PRIMARY KEY,
    name text NOT NULL,
    state text NOT NULL,
    FOREIGN KEY (name, state) 
        REFERENCES fsm.transition (name, from_state)
);


CREATE FUNCTION fsm.transitions_for(bigint) RETURNS SETOF fsm.transition AS $$
    SELECT t.* FROM fsm.transition t, fsm.machine m
    WHERE m.id = $1 AND t.name = m.name AND t.from_state = m.state;
$$ LANGUAGE sql;


CREATE FUNCTION fsm.states_for(text) RETURNS SETOF text AS $$
    SELECT from_state FROM fsm.transition WHERE name = $1;
$$ LANGUAGE sql;


CREATE FUNCTION fsm.do_transition(bigint, text) RETURNS fsm.machine AS $$
       UPDATE fsm.machine m SET state = t.to_state
       FROM fsm.transition t
       WHERE
           m.id = $1 AND
           m.name = t.name AND
           t.from_state = m.state AND
           t.transition = $2
       RETURNING m;
$$ LANGUAGE sql;


CREATE FUNCTION fsm.check_valid_state_update() RETURNS trigger AS $$
    BEGIN
        IF NEW.state NOT IN (SELECT to_state FROM fsm.transitions_for(NEW.id)) THEN
            RAISE EXCEPTION 'Invalid transition %', NEW.state;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER fsm_machine_check_valid_update_trigger
    BEFORE UPDATE OF state ON fsm.machine
    FOR EACH ROW
    EXECUTE PROCEDURE fsm.check_valid_state_update();


CREATE FUNCTION fsm.check_valid_state_insert() RETURNS trigger AS $$
    BEGIN
        IF NEW.name not in (select name from fsm.transition) THEN
            RAISE EXCEPTION 'Invalid FSM name %', NEW.name;
        END IF;
        IF NEW.state NOT IN (SELECT * FROM fsm.states_for(NEW.name)) THEN
            RAISE EXCEPTION 'Invalid initial state %', NEW.state;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER fsm_machine_check_valid_insert_trigger
    BEFORE INSERT ON fsm.machine
    FOR EACH ROW
    EXECUTE PROCEDURE fsm.check_valid_state_insert();

COMMIT;
