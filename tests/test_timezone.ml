(*i $Id: test_timezone.ml,v 1.5 2003-07-16 09:04:30 signoles Exp $ i*)

Printf.printf "\nTests of Time_Zone:\n\n";;

open Time_Zone;;
include Gen_test;;
reset ();;

test (current () = UTC) "current () = UTC";;
change Local;;
test (current () = Local) "current () = Local";;
test (gap UTC (UTC_Plus (-5)) = -5) "gap UTC (UTC_Plus (-5)) = -5";;
let g6 = UTC_Plus 6;;
test 
  (gap g6 Local = gap g6 UTC + gap UTC Local)
  "gap g6 Local = gap g6 UTC + gap UTC Local";;
test_exn (lazy (change (UTC_Plus 13))) "change 13";;
test_exn (lazy (change (UTC_Plus (-15)))) "change (-15)";;
change (UTC_Plus 4);;
test (from_gmt () = 4) "from_gmt () = 4";;
test (to_gmt () = -4) "to_gmt () = -4";;

let ok = nb_ok ();;
let bug = nb_bug ();;
Printf.printf "\ntests ok : %d; tests ko : %d\n" ok bug;;
