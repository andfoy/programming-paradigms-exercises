local Accumulate AccumulateTail AccumulateMap L Term Comb in
   fun {Accumulate Combiner Zero TerminateCondition First Next Last}
      case {TerminateCondition First} of true then Zero
      [] false then
	 case Last of H|T then  
	    {Combiner First {Accumulate Combiner Zero TerminateCondition Next H T}}
	 [] nil then {Combiner First {Accumulate Combiner Zero TerminateCondition Next nil nil}}
	 [] Value then {Combiner First {Accumulate Combiner Zero TerminateCondition Next Value nil}}
	 end
      end
   end

   fun {AccumulateTail Combiner Zero TerminateCondition First Next Last}
      case {TerminateCondition First} of true then Zero
      [] false then
	 case Last of H|T then
	    {AccumulateTail Combiner {Combiner Zero First} TerminateCondition Next H T}
	 [] nil then {AccumulateTail Combiner {Combiner Zero First} TerminateCondition Next nil nil}
         %[] Value then {Accumulate Combiner {Combiner Zero First} TerminateCondition Next Value nil}
	 end
      end
   end

   fun {AccumulateMap Combiner Zero TerminateCondition First Next Last}
      local R in
	 {FoldL First|Next|Last Combiner Zero R}
	 R
      end
   end

   L = [22 23 24 25 26 27 28 29 30]
   Comb = fun {$ X Y} X - Y end
   Term = fun {$ X}
	     case X of nil then true
	     else false
	     end
	  end
   {Show {Accumulate Comb 0 Term 20 21 L}}
   {Show {AccumulateTail Comb 0 Term 20 21 L}}
   {Show {AccumulateMap Comb 0 Term 20 21 L}}
end