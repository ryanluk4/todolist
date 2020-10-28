# To-do List in OCaml

## Motivation

I have a basic understanding of OCaml and the environment through another [project](https://github.com/ryanluk4/ocaML), but I wanted a little more development experience. I also have some self-taught SQL knowledge, but no formal projects or exposure to PostegreSQL.

I also need a to-do list.

## Installation

1. `apt-get install opam m4`

2. `opam init` For WSL, include `--disable-sandboxing`

3. `eval $(opam env)` to update shell environment

4. (_Optional_) `opam switch create 4.11.1` to change switch (version)

5. (_Optional_) `opam switch set-description "<desc>"` to add a description to existing switch

6. `opam install .` to install dependencies from the `todolist.opam` project packaging

7. `apt show postgresql` to show the latest version of PostgreSQL

8. `apt install postgresql-12` I needed to specify a version? An error might occur? Pretty sure `apt install postgresql` is fine. Versions 10+ include `postgresql-contrib`

9. `service --status-all` to see all of the current services

10. `service postgresql start` to start a postgresql instance

11. If you have a PostgreSQL role:

```shell
psql
```

```sql
\conninfo
```

This confirms you are able to enter the instance.

12. If you do not have a PostgreSQL role:

```shell
sudo su - postgres

psql

CREATE ROLE <username> ;

ALTER USER <username> WITH SUPERUSER ;
```

On a fresh install, there should only be a superuser that is active when entering into the `psql` instance. You can make the `<username>` match your Linux/Ubuntu username and run `export PGPASSWORD="<password>"` to allow `psql` to be called top-level from the user.

13. More commands:

```sql
\l /* list databases */

createdb /*<name>*/ /* creates a database, need to have same name as user? */

\dt /* list tables */

\du /* list roles */
```

## Basic Opam/Dune Commands

```shell
eval $(opam env)
```

```shell
opam list

opam switch
```

```shell
dune clean

dune build

dune exec ./<EXECUTABLE>
```

## Utop Commands

```ocaml
#require <library> ;;

open <library> ;;
```

## Build

Dune can build libraries or executables for OCaml via the `dune` file. This file compilation is attached to the `Lib` library. Under a `dune build` or `dune utop`, the `Lib` library can be opened. The `dune` file also silences certain warnings. The ones commented (26 = unused variables, 33 = unused openings, 35 = unused for loop indices) I ran into while testing and the rest are copied from the [Jane Street workshop](https://github.com/ryanluk4/learn-ocaml-workshop).

## To-do List

This project is a library, available to use through `utop` top-level. `todo.mli` defines our functions and `todo.ml` holds the implementations. The library connects into the 5432 port (PostgreSQL) using the `Caqti` module. There are some basic functions:

- `create_table () ;;` Creates the `todo` table
- `drop_table () ;;` Drops the `todo` table
- `get_all () ;;` Returns list with query for all items
- `add <item : string> <due_date : string> ;;` Add item with due date
- `remove <index : int> ;;` Remove item via index
- `clear () ;;` Clear all items from table

Run these functions with `dune utop`:

```ocaml
open Lib ;;

(* creates `todo` table *)
Todo.create_table () ;;

(* adds first item *)
Todo.add "my first item" "2020-10-31" ;;

(* adds a second item *)
Todo.add "my second item" "2020-11-01" ;;

(* gets all items *)
Todo.get_all () ;;

(* removes the second item *)
Todo.remove 1 ;;

(* removes all items *)
Todo.clear () ;;

(* drops `todo` table *)
Todo.drop_table () ;;
```