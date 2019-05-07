local RandList Reverse ReverseTCO L1 S1 E1 S2 E2 in
   fun {RandList Len}
      local RandL in
	 fun {RandL Len Accum}
	    case Len of 0 then Accum
   	    else {RandL Len-1 {OS.rand}|Accum}
   	    end
   	 end
   	 {RandL Len nil}
      end
   end

   fun {Reverse L}
      case L of H|nil then H
      [] H|T then {Reverse T}|H
      end
   end

   fun {ReverseTCO L}
      local Rev in
	 fun {Rev L Accum}
	    case L of nil then Accum
	    [] H|T then {Rev T H|Accum}
            end
	 end
	 {Rev L nil}
      end
   end

   % {Show {OS.rand} mod 20}
   L1 = {RandList 5000000}
   {Time.time S1}
   {Show {Reverse L1}}
   {Time.time E1}
   {Show E1 - S1}
   {Time.time S2}
   {Show {ReverseTCO L1}}
   {Time.time E2}
   {Show E2 - S2}
end