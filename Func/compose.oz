local Compose F1 F2 Comp in
   fun {Compose F G}
      fun {$ X}
	 {F {G X}}
      end
   end
   F1 = fun {$ X} ~X end
   F2 = fun {$ X} X * X * X end
   Comp = {Compose F2 F1}
   {Show {Comp 2}}
end