local CountStrings in
   fun {CountStrings L}
      local CountVal in
	 fun {CountVal L RecordCount}
	    case L of nil then {Record.toListInd RecordCount}
	    [] H|T then
	       local StrCount NewRecord in
		  {CondSelect RecordCount H 0 StrCount}
		  NewRecord = {AdjoinList RecordCount [H#(StrCount + 1)]}
		  {CountVal T NewRecord}
	       end
	    end
	 end 
	 {CountVal L nil}
      end
   end
   {Show {CountStrings ['hola'  'mundo'  'hola']}}
end