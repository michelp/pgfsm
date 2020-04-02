# pgfsm
Simple SQL finite state machine for Postgres

This is some example code on how to store a simple state machine in
SQL.

There are two tables, fsm.machine and fsm.transition.  The machine
table has insert and update triggers to ensure that every row is in a
valid state.  The transition table is where transition between states
are defined.

There is a pgtap test in test.sql that illustrates the technique.
