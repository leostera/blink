open Riot

module type Intf = sig
  module Request : sig
    val to_buffer :
      Uri.t -> Http.Request.t -> ?body:IO.Buffer.t -> unit -> IO.Buffer.t
  end

  module Response : sig
    val of_reader :
      'src IO.Reader.t ->
      buf:IO.Buffer.t ->
      ( Msg.message list,
        [> `Closed | `Eof | `Response_parsing_error | `Unix_error of Unix.error ]
      )
      result
  end
end

module Http1 : Intf = Http1
module Http2 : Intf = Http2

module Negotiate = struct
  let of_uri uri =
    match Uri.scheme uri |> Option.map String.lowercase_ascii with
    | Some "https" -> (module Http2 : Intf)
    | Some "http" | _ -> (module Http1 : Intf)
end
