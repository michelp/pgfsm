\echo Use "CREATE EXTENSION pgfsm" to load this file. \quit


CREATE TABLE transition (
    name text NOT NULL,
    from_state text NOT NULL,
    transition text,
    to_state text,
    PRIMARY KEY (name, from_state)
);


CREATE TABLE machine (
    id BIGSERIAL PRIMARY KEY,
    name text NOT NULL,
    state text NOT NULL,
    FOREIGN KEY (name, state)
        REFERENCES transition (name, from_state)
);


CREATE FUNCTION transitions_for(bigint) RETURNS SETOF transition AS $$
    SELECT t.* FROM transition t, machine m
    WHERE
        m.id = $1 AND
        t.name = m.name AND
        t.from_state = m.state;
$$ LANGUAGE sql;


CREATE FUNCTION states_for(text) RETURNS SETOF text AS $$
    SELECT from_state FROM transition WHERE name = $1;
$$ LANGUAGE sql;


CREATE FUNCTION do_transition(bigint, text) RETURNS SETOF machine AS $$
    BEGIN
        UPDATE machine m SET state = t.to_state
        FROM transition t
        WHERE
            m.id = $1 AND
            m.name = t.name AND
            t.from_state = m.state AND
            t.transition = $2;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No valid transition for % named %', $1, $2;
        END IF;
        RETURN QUERY SELECT * FROM machine WHERE id = $1;
    END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION check_valid_state_update() RETURNS trigger AS $$
    BEGIN
        IF NEW.state NOT IN (SELECT to_state FROM transitions_for(NEW.id)) THEN
            RAISE EXCEPTION 'Invalid transition %', NEW.state;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER fsm_machine_check_valid_update_trigger
    BEFORE UPDATE OF state ON machine
    FOR EACH ROW
    EXECUTE PROCEDURE check_valid_state_update();


CREATE FUNCTION check_valid_state_insert() RETURNS trigger AS $$
    BEGIN
        IF NOT EXISTS (SELECT * FROM states_for(NEW.name)) THEN
            RAISE EXCEPTION 'Invalid initial state %', NEW.state;
        END IF;
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;


CREATE CONSTRAINT TRIGGER fsm_machine_check_valid_insert_trigger
    AFTER INSERT ON machine
    FOR EACH ROW
    EXECUTE PROCEDURE check_valid_state_insert();
