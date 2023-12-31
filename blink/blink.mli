(** {1 Blink}

*)

open Riot

(** {2 Connection}

*)
module Connection : sig
  type t

  type message =
    [ `Data of IO.Buffer.t
    | `Done
    | `Headers of Http.Header.t
    | `Status of Http.Status.t ]
end

val ( let* ) : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result

val connect :
  Uri.t ->
  ( Connection.t,
    [> `Closed
    | `Invalid_uri of Uri.t
    | `Tls_error of exn
    | `Unix_error of Unix.error
    | `Msg of string ] )
  result

val request :
  Connection.t ->
  Http.Request.t ->
  ?body:IO.Buffer.t ->
  unit ->
  (Connection.t, [> `Closed | `Unix_error of Unix.error ]) result

val stream :
  Connection.t ->
  ( Connection.t * Connection.message list,
    [> `Closed | `Eof | `Response_parsing_error | `Unix_error of Unix.error ]
  )
  result
