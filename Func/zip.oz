local Zipwithfun in
fun {Zipwithfun L1 L2 Fn}
      local Zip in
	 fun {Zip L1 L2 Accum}
	    case L1 of nil then {List.reverse Accum}
	    [] H|T then
	       case L2 of nil then {List.reverse Accum}
	       [] H2|T2 then {Zip T T2 {Fn H H2}|Accum}
	       end
	    end
	 end
	 {Zip L1 L2 nil}
      end
end
{Show {Zipwithfun [1 2 3 4] [1 2 3 4 5] fun {$ A1 A2} A1+A2 end}}
end

