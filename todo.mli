type todo_item = {
	id: int;
	content: string;
}

type error =
	| Database_error of string

val create_table : unit -> (unit, error) result Lwt.t
val drop_table : unit -> (unit, error) result Lwt.t

val get_all : unit -> (todo_item list, error) result Lwt.t
val add : string -> (unit, error) result Lwt.t
val remove : int -> (unit, error) result Lwt.t
val clear : unit -> (unit, error) result Lwt.t