(* 
	Ryan Luk
	ryanluk4@gmail.com

	Todo library, available via utop

*)

(* postgres port 5432 *)
let connection_url = "postgresql://localhost:5432"

(* connection pool for queries/operations *)
let pool =
	match Caqti_lwt.connect_pool ~max_size:5 (Uri.of_string connection_url) with
	| Ok pool -> pool
	| Error err -> failwith (Caqti_error.show err)

(* todo item type definition *)
type todo_item = {
	id: int;
	content: string;
}
(* database error type definition *)
type error =
	| Database_error of string

(* Looked up this database error handling *)
(* Helper method to map Caqti errors to our own error type. 
   val or_error : ('a, [> Caqti_error.t ]) result Lwt.t -> ('a, error) result Lwt.t *)
let or_error m =
	match%lwt m with
	| Ok a -> Ok a |> Lwt.return
	| Error e -> Error (Database_error (Caqti_error.show e)) |> Lwt.return

(* CREATE MAIN TABLE *)

(* execution query 
	unit func
	create table
	with given columns
*)

let create_table_query =
	Caqti_request.exec 
		Caqti_type.unit 
		{|
			CREATE TABLE todo 
				( 
					id SERIAL NOT NULL PRIMARY KEY,
					content VARCHAR
				)
		|}

(* function to call sql query 
	call execution query
	push to pool
*)

let create_table () =
	let create_query (module C : Caqti_lwt.CONNECTION) = C.exec create_table_query ()
	in
	Caqti_lwt.Pool.use create_query pool |> or_error

(* GET ALL *)

(* collection query 
	unit func
	query object tuple
*)

let get_all_query =
	Caqti_request.collect 
		Caqti_type.unit
		Caqti_type.(tup2 int string)
		"SELECT id, content FROM todo"

(* function to call sql query 
	call collection query
	fold query
	push to pool
*)

let get_all () =
	let get_all' (module C : Caqti_lwt.CONNECTION) = 
		C.fold get_all_query (fun (id, content) acc -> 
			{ id; content } :: acc
		) () []
	in
	Caqti_lwt.Pool.use get_all' pool |> or_error

(* DROP MAIN TABLE *)

(* execution query 
	unit func
	drop table
*)

let drop_query =
	Caqti_request.exec 
		Caqti_type.unit
		"DROP TABLE todo"

(* function to call sql query 
	call execution query
	push to pool
*)

let drop_table () =
	let delete_query (module C : Caqti_lwt.CONNECTION) = C.exec drop_query ()
	in
	Caqti_lwt.Pool.use delete_query pool |> or_error

(* ADD *)
  
(* execution query
	query insert string
*)

let add_query =
	Caqti_request.exec 
		Caqti_type.string 
		"INSERT INTO todo (content) VALUES (?)"

(* function to call sql query
	call execution query
	push to pool
*)

let add content =
	let add' content (module C : Caqti_lwt.CONNECTION) = C.exec add_query content
	in
	Caqti_lwt.Pool.use (add' content) pool |> or_error

(* REMOVE *)

(* execution query
	query delete int
*)

let remove_query =
	Caqti_request.exec
		Caqti_type.int
		"DELETE FROM todo WHERE id = ?"

(* function to call sql query
	call query
	push to pool
*)

let remove id =
	let remove' id (module C : Caqti_lwt.CONNECTION) = C.exec remove_query id
	in
	Caqti_lwt.Pool.use (remove' id) pool |> or_error

(* CLEAR ALL *)

(* execution query
	unit func
	truncate table
*)

let clear_query =
	Caqti_request.exec
		Caqti_type.unit
		"TRUNCATE TABLE todo"

(* function to call sql query
	call execution query
	push to pool
*)

let clear () =
	let clear' (module C : Caqti_lwt.CONNECTION) = C.exec clear_query ()
	in
	Caqti_lwt.Pool.use clear' pool |> or_error