(*
 * Calendar library
 * Copyright (C) 2003 Julien SIGNOLES
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License version 2, as published by the Free Software Foundation.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * 
 * See the GNU Library General Public License version 2 for more details
 *)

(*i $Id: time.ml,v 1.4 2003-07-07 17:34:56 signoles Exp $ i*)

(*S Datatypes. *)

(* A time is represents by a number of seconds in GMT.
   Outside this module, a time is interpreted in the current time zone.
   So, each operations have to coerce a given time according to the current
   time zone. *)
type t = int

type field = [ `Hour | `Minut | `Second ]

(*S Conversions. *)

let convert t t1 t2 = t + 3600 * Time_Zone.gap t1 t2

let to_gmt t = convert t (Time_Zone.current ()) Time_Zone.GMT

let from_gmt t = convert t Time_Zone.GMT (Time_Zone.current ())

let normalize t = 
  let t = from_gmt t in
  let t_mod, t_div = to_gmt (t mod 86400), t / 86400 in
  if t < 0 then t_mod + 86400, t_div - 1 else t_mod, t_div

(*S Constructors. *)

let make h m s = to_gmt (h * 3600 + m * 60 + s)

let midnight () = to_gmt 0

let midday () = to_gmt 43200

let now () =
  let now = Unix.gmtime (Unix.gettimeofday ()) in
  3600 * now.Unix.tm_hour + 60 * now.Unix.tm_min + now.Unix.tm_sec

(*S Getters. *)

let hour t = from_gmt t / 3600

let minut t = from_gmt t mod 3600 / 60

let second t = from_gmt t mod 60

let to_hours t = float_of_int (from_gmt t) /. 3600.

let to_minuts t = float_of_int (from_gmt t) /. 60.

let to_seconds t = from_gmt t

(*S Boolean operations. *)

let compare = (-)

let is_pm t = let t, _ = normalize t in t < midday ()

let is_am t = let t, _ = normalize t in t >= midday ()

(*S Coercions. *)

let to_string t = 
  string_of_int (hour t) ^ "-" ^ string_of_int (minut t) 
  ^ "-" ^ string_of_int (second t)

let from_string s =
  match List.map int_of_string (Str.split (Str.regexp "-") s) with
    | [ h; m; s ] -> make h m s
    | _ -> raise (Invalid_argument (s ^ " is not a time"))

let from_hours t = to_gmt (int_of_float (t *. 3600.))

let from_minuts t = to_gmt (int_of_float (t *. 60.))

let from_seconds t = to_gmt t

(*S Period. *)

module Period = struct
  type t = int

  let make h m s = h * 3600 + m * 60 + s

  let hour h = h * 3600

  let minut m = m * 60

  let second s = s

  let empty = 0

  let add = (+)

  let sub = (-)

  let mul = ( * )

  let div = (/)

  let opp x = - x

  let compare = (-)
end

(*S Arithmetic operations on times and periods. *)

let add = (+)

let sub = (-)

let rem = (-)

let next x = function
  | `Hour   -> x + 3600
  | `Minut  -> x + 60
  | `Second -> x + 1

let prev x = function
  | `Hour   -> x - 3600
  | `Minut  -> x - 60
  | `Second -> x - 1
