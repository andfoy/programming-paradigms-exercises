local
   X = 'Unexpected Parenthesis'
   Y = 'Missing Parenthesis'
   Clean
   Tokenize
   ToAtom
   Read
   Symbol
   Parse
   Parser
   Syntax

   % ________________________________ %

   Test = "(defvar X) (defun Fact N (if (= N 0) 1 (* N (Fact(- N 1))))) (unify X (Fact 5))"
   Test1 = "(defvar X) (defun Fact N (if (= N 0) 1 (* N (Fact(- N 1)))))"
   Test2 = "(unify X (Fact 5))"
   Test3 = "(defun Fact N (if (= N 0) 1 (* N (Fact(- N 1)))))"
in

   fun {Clean Line Acc}
      case Line of nil then {Reverse Acc}
      [] H|T then
	 if H == 40 then {Clean T {Append [32 40 32] Acc}}
	 elseif H == 41 then {Clean T {Append [32 41 32] Acc}}
	 else {Clean T {Append [H] Acc}}
	 end
      end
   end

   % This funciton returns a list of tokens
   fun {Tokenize Line}
      {String.tokens Line 32}
   end


   fun {ToAtom Line}
      local
	 AtomList = {NewCell nil}
      in
	 for I in Line continue:C do
	    if I == nil then {C}
	    else
	       AtomList := {Append @AtomList [{Symbol I}]}
	    end
	 end
	 @AtomList
      end
   end

   %This function turns strings into atoms and numbers into Integers
   fun {Symbol S}
      if {And ({Nth S 1} =< 57) ({Nth S 1} >= 48)} then
	 {String.toInt S}
      else
	 {String.toAtom S}
      end
   end

   % This function checks syntax and groups separate List commands
   % and appends them to a list to be processed.
   fun {Parse Line Acc Open Close Statement}
      case Line of nil then
	 if Open > Close then {Exception.'raise' Y} end
	 Acc
      [] H|T then
	 if Open < Close then {Exception.'raise' X} end
	 if H == '(' then
	    {Parse T Acc (Open + 1) Close {Append Statement [H]}}
	 elseif H == ')' then
	    if ({Number.'-' Open Close} == 1) then
	       {Parse T {Append Acc [{Append Statement [H]}]} 0 0 nil}
	    else
	       {Parse T Acc Open (Close + 1) {Append Statement [H]}}
	    end
	 else
	    {Parse T Acc Open Close {Append Statement [H]}}
	 end
      end
   end

   % This function reads the list of commands and recursively
   % builds a tree to be evaluated
   fun {Read MList}
      fun {Buildlist Li Acc} Lii in
	 case Li of nil then
	    result(acc:Acc rtail:nil)
	 [] H|T then
	    if H == '(' orelse H == ')' then
	       if H == '(' then
		  Lii = {Buildlist T nil}
		  {Buildlist Lii.rtail {Append Acc [Lii.acc]}}
	       else
		  result(acc:Acc rtail:T)
	       end
	    else
	       {Buildlist T {Append Acc [H]}}
	    end
	 end
      end
   in
      {Buildlist MList nil}.acc
   end


   fun {Parser Line}
      local
	 FinalOutput = {NewCell nil}
	 CleanTokens = {Clean Line nil}
	 Tokens = {Tokenize CleanTokens}
	 AtomList = {ToAtom Tokens}
	 ListToParse = {Parse AtomList nil 0 0 nil}
      in
	 for I in ListToParse do
	    if @FinalOutput == nil then
	       FinalOutput := {Read I}
	    else
	       FinalOutput := {Append @FinalOutput {Read I}}
	    end
	 end
	 if {Length @FinalOutput} == 1 then
	    {Nth @FinalOutput 1}
	 else
	    @FinalOutput
	 end
      end
   end

   {Show 'Parsing...'}
   {Show {Parser Test}}

end

%_______________________________________________________________%
