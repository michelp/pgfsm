BEGIN;
DROP SCHEMA IF EXISTS fsm CASCADE;
CREATE SCHEMA fsm;


CREATE TABLE fsm.machine (
    id BIGSERIAL PRIMARY KEY,
    name text NOT NULL,
    state text NOT NULL
);


CREATE TABLE fsm.transition (
    name text NOT NULL,
    from_state text NOT NULL,
    transition text,
    to_state text
);
CREATE UNIQUE INDEX fsm_transition_name_from_state_transition_idx 
    ON fsm.transition (name, from_state, transition);


CREATE FUNCTION fsm.transitions_for(bigint) RETURNS SETOF fsm.transition AS $$
    select t.* from fsm.transition t, fsm.machine m 
    where m.id = $1 and t.name = m.name and t.from_state = m.state;
$$ LANGUAGE sql;


CREATE FUNCTION fsm.states_for(text) RETURNS SETOF text AS $$
    select from_state from fsm.transition where name = $1;
$$ LANGUAGE sql;


CREATE FUNCTION fsm.do_transition(bigint, text) RETURNS fsm.machine AS $$
       UPDATE fsm.machine m set state = t.to_state 
       from fsm.transition t 
       where m.id = $1 and m.name = t.name and t.from_state = m.state and t.transition = $2 
       returning m;
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
        IF NEW.state NOT IN (SELECT * FROM fsm.states_for(NEW.name)) THEN
            RAISE EXCEPTION 'Invalid initial state %', NEW.state;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

COMMIT;
