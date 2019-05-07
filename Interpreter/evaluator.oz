local Eval EvalExpr EvalDefVar EvalDefFun EvalIf EvalUnify
      EvalEq EvalNeq EvalLe EvalLeq EvalGe EvalGeq EvalAnd EvalOr EvalNot
      EvalMinus EvalPlus EvalMultiplication EvalDivision EvalBinary
      EvalUnary EvalShortCircuit EvalPrint EvalList EvalFunc EvalValue
      Program in

    fun {Eval Repr Ctx}
        local InnerEval in
            fun {InnerEval Repr Ctx RetValue}
                case Repr of nil then [RetValue Ctx]
                [] Expr|Rest then
                    case Expr of _|_ then
                        case Rest of _|_ then
                            case {EvalExpr Expr Ctx} of nil|NewCtx|nil then
                                {InnerEval Rest NewCtx nil}
                            [] Result|NewCtx|nil then {InnerEval Rest NewCtx Result}
                            end
                        else
                            {EvalExpr Expr Ctx}
                        end
                    [] _ then
                        {EvalExpr Repr Ctx}
                    end
                [] Expr then
                    case {EvalExpr Expr Ctx} of Result|NCtx|nil then
                        [Result NCtx]
                    end
                end
            end
            {InnerEval Repr Ctx nil}
        end
    end

    fun {EvalExpr Expr Ctx}
        case Expr of nil then nil
        [] Name|Args then
            case Name of 'defvar' then {EvalDefVar Args Ctx}
                [] 'defun' then {EvalDefFun Args Ctx}
                [] 'if' then {EvalIf Args Ctx}
                [] 'unify' then {EvalUnify Args Ctx}
                [] '!=' then {EvalNeq Args Ctx}
                [] '&' then {EvalAnd Args Ctx false}
                [] '&&' then {EvalAnd Args Ctx true}
                [] '|' then {EvalOr Args Ctx false}
                [] '||' then {EvalOr Args Ctx true}
                [] '!' then {EvalNot Args Ctx}
                [] '=' then {EvalEq Args Ctx}
                [] '<' then {EvalLe Args Ctx}
                [] '<=' then {EvalLeq Args Ctx}
                [] '>' then {EvalGe Args Ctx}
                [] '>=' then {EvalGeq Args Ctx}
                [] '-' then {EvalMinus Args Ctx}
                [] '+' then {EvalPlus Args Ctx}
                [] '*' then {EvalMultiplication Args Ctx}
                [] '/' then {EvalDivision Args Ctx}
                [] 'print' then {EvalPrint Args Ctx}
                [] _ then
                    case Args of nil then {EvalValue Name Ctx}
                    [] _ then
                        local IsAtom in
                            {Atom.is Name IsAtom}
                            case IsAtom of true then {EvalFunc Name Args Ctx}
                            [] false then {EvalList Expr Ctx}
                            end
                        end
                    end
            end
        [] Value then {EvalValue Value Ctx}
        end
    end

    fun {EvalBinary Fun Args Ctx}
        case Args of Arg1|Arg2|nil then
            case {Eval Arg1 Ctx} of Value1|Ctx1|nil then
                case {Eval Arg2 Ctx1} of Value2|Ctx2|nil then
                    local RealValue in
                        RealValue = case Value2 of Val|MoreCtx|nil then Val
                        else Value2
                        end
                        [{Fun Value1 RealValue} Ctx2]
                    end
                end
            end
        [] _ then {Exception.error 'Binary operators recieve only two parameters'}
        end
    end

    fun {EvalShortCircuit Fun Args Ctx Cut}
        case Args of Arg1|Arg2|nil then
            case {Eval Arg1 Ctx} of Value1|Ctx1|nil then
                case Value1 == Cut of true then [Value1 Ctx1]
                [] false then
                    case {Eval Arg2 Ctx1} of Value2|Ctx2|nil then
                        [{Fun Value1 Value2} Ctx2]
                    end
                end
            end
        [] _ then {Exception.error 'Short circuit operators recieve only two parameters'}
        end
    end

    fun {EvalUnary Fun Arg Ctx}
        case Arg of H|nil then
            case {Eval H Ctx} of Value|NewCtx|nil then
                [{Fun Value} NewCtx]
            end
        [] H|T then
            {Exception.error 'Unary only recieve single arguments'}
        else
             case {Eval Arg Ctx} of Value|NewCtx|nil then
                [{Fun Value} NewCtx]
            end
        end
    end

    fun {EvalEq Args Ctx}
        local EqFun in
            fun {EqFun Arg1 Arg2}
                Arg1 == Arg2
            end
            {EvalBinary EqFun Args Ctx}
        end
    end

    fun {EvalNeq Args Ctx}
        local NeqFun in
            fun {NeqFun Arg1 Arg2}
                Arg1 \= Arg2
            end
            {EvalBinary NeqFun Args Ctx}
        end
    end

    fun {EvalGe Args Ctx}
        local GeFun in
            fun {GeFun Arg1 Arg2}
                Arg1 > Arg2
            end
            {EvalBinary GeFun Args Ctx}
        end
    end

    fun {EvalGeq Args Ctx}
        local GeFun in
            fun {GeFun Arg1 Arg2}
                Arg1 >= Arg2
            end
            {EvalBinary GeFun Args Ctx}
        end
    end

    fun {EvalLe Args Ctx}
        local LeFun in
            fun {LeFun Arg1 Arg2}
                Arg1 < Arg2
            end
            {EvalBinary LeFun Args Ctx}
        end
    end

    fun {EvalLeq Args Ctx}
        local LeqFun in
            fun {LeqFun Arg1 Arg2}
                Arg1 =< Arg2
            end
            {EvalBinary LeqFun Args Ctx}
        end
    end

    fun {EvalPlus Args Ctx}
        local PlusFun in
            fun {PlusFun Arg1 Arg2}
                Arg1 + Arg2
            end
            {EvalBinary PlusFun Args Ctx}
        end
    end

    fun {EvalMinus Args Ctx}
        local MinusFun in
            case Args of Arg1|Arg2|nil then
                fun {MinusFun Arg1 Arg2}
                    Arg1 - Arg2
                end
                {EvalBinary MinusFun Args Ctx}
            [] Arg then
                fun {MinusFun Arg}
                    ~Arg
                end
                {EvalUnary MinusFun Arg Ctx}
            end
        end
    end

    fun {EvalMultiplication Args Ctx}
        local MultiplicationFun in
            fun {MultiplicationFun Arg1 Arg2}
                Arg1 * Arg2
            end
            {EvalBinary MultiplicationFun Args Ctx}
        end
    end

    fun {EvalDivision Args Ctx}
        local DivisionFun in
            fun {DivisionFun Arg1 Arg2}
                Arg1 / Arg2
            end
            {EvalBinary DivisionFun Args Ctx}
        end
    end

    fun {EvalAnd Args Ctx ShortCircuit}
        local AndFun in
            fun {AndFun Arg1 Arg2}
                {And Arg1 Arg2}
            end
            case ShortCircuit of false then {EvalBinary AndFun Args Ctx}
            [] true then {EvalShortCircuit AndFun Args Ctx false}
            end
        end
    end

    fun {EvalOr Args Ctx ShortCircuit}
        local OrFun in
            fun {OrFun Arg1 Arg2}
                {Or Arg1 Arg2}
            end
            case ShortCircuit of false then {EvalBinary OrFun Args Ctx}
            [] true then {EvalShortCircuit OrFun Args Ctx true}
            end
        end
    end

    fun {EvalNot Args Ctx}
        local NotFun in
            fun {NotFun Arg}
                {Not Arg}
            end
            {EvalUnary NotFun Args Ctx}
        end
    end

    fun {EvalPrint Args Ctx}
        case {Eval Args Ctx} of Result|NewCtx|nil then
            local ActualResult in
                ActualResult = case Result of Res|NewCtx|nil then Res
                else Result
                end
                {Show ActualResult}
                [nil NewCtx]
            end
        end
    end

    fun {EvalIf Args Ctx}
        case Args of Cond|PosBranch|Else|nil then
            local CondEval in
                CondEval = {Eval Cond Ctx}
                case CondEval of true|PCtx|nil then
                    {Eval PosBranch PCtx}
                [] false|NCtx|nil then
                    {Eval Else NCtx}
                end
            end
        end
    end

    fun {EvalFunc Name Args Ctx}
        local InitArgs FuncDef SignatureArgs Body in
            fun {InitArgs SigArgs Args Ctx}
                case SigArgs of nil then
                    case Args of nil then Ctx
                    [] _ then
                        {Exception.error 'Function signature has less parameters than provided'}
                    end
                [] Arg|T then
                    case Args of nil then
                        {Exception.error 'Function expects more parameters than provided'}
                    [] Value|Rest then
                        case {Eval Value Ctx} of Result|Ctx2|nil then
                            local NewCtx in
                                NewCtx = {AdjoinList Ctx2 [Arg#Result]}
                                {InitArgs T Rest NewCtx}
                            end
                        end
                    end
                end
            end

            {CondSelect Ctx Name nil FuncDef}
            case FuncDef of nil then {Exception.error 'Undefined function'}
            [] _ then
                {CondSelect FuncDef args nil SignatureArgs}
                {CondSelect FuncDef body nil Body}
                local NewCtx in
                    NewCtx = {InitArgs SignatureArgs Args Ctx}
                    [{Eval Body NewCtx} Ctx]
                end
            end
        end
    end

    fun {EvalList Values Ctx}
        local AccumList in
            fun {AccumList List Accum Ctx}
                case List of nil then [{List.reverse Accum} Ctx]
                [] H|T then
                    case {EvalExpr H Ctx} of Result|NewCtx then
                        {AccumList T Result|Accum NewCtx}
                    end
                end
            end
            {AccumList Values nil Ctx}
        end
    end

    fun {EvalValue Value Ctx}
        local IsAtom in
            {Atom.is Value IsAtom}
            case IsAtom of true then
                case Value of 'true' then [true Ctx]
                [] 'false' then [false Ctx]
                [] 'nil' then [nil Ctx]
                [] _ then
                    local X in
                        {CondSelect Ctx Value nil X}
                        case X of nil then [nil Ctx] % {Exception.error 'Unbound variable'}
                        [] _ then [X Ctx]
                        end
                    end
                end
            [] false then
                local IsNumber in
                    {Number.is Value IsNumber}
                    case IsNumber of true then [Value Ctx]
                    [] false then {Exception.error 'Undefined type'}
                    end
                end
            end
        end
    end

    fun {EvalDefFun NameArgsBody Ctx}
        % {Show Name}
        % {Show Ctx}
        % {Show NameArgsBody}
        local X NameArgs NewArgs Body NewCtx FuncRecord in
            % {Show X}
            {List.takeDrop NameArgsBody {List.length NameArgsBody}-1 NameArgs Body}
            case NameArgs of Name|Args then
                {CondSelect Ctx Name nil X}
                % {Show X}
                case X of nil then
                    % {Show Args}
                    NewArgs = case Args of H|T then Args
                    [] nil then nil
                    [] Value then [Args]
                    end
                    FuncRecord = {AdjoinList nil [args#NewArgs body#Body]}
                    NewCtx = {AdjoinList Ctx [Name#FuncRecord]}
                    % {Show NewCtx}
                    [nil NewCtx]
                [] _ then {Exception.error 'Name already taken'}
                end
            end
        end
    end

    fun {EvalDefVar Args Ctx}
        case Args of nil then [nil Ctx]
        [] Var|Rest then
            local X in
                {CondSelect Ctx Var nil X}
                case X of nil then
                    local NewCtx in
                        NewCtx = {AdjoinList Ctx [Var#X]}
                        {EvalDefVar Rest NewCtx}
                    end
                [] _ then {Exception.error 'Variable was already declared'}
                end
            end
        end
    end

    fun {EvalUnify Args Ctx}
        case Args of Left|Right|nil then
            case {Eval Left Ctx} of Result1|Ctx1|nil then
                case {Eval [Right] Ctx} of Result2|Ctx2|nil then
                    case Result1 of nil then
                        case Left of Var|nil then
                            local NewCtx in
                                NewCtx = {AdjoinList Ctx [Var#Result2]}
                                [nil NewCtx]
                            end
                        [] Var then
                            local NewCtx in
                                local RealResult in
                                    RealResult = case Result2 of R|Ctx2|nil then
                                        R
                                    else
                                        Result2
                                    end
                                    NewCtx = {AdjoinList Ctx [Var#RealResult]}
                                    [nil NewCtx]
                                end
                            end
                        end
                    [] _ then Result1 == Result2
                    end
                end
            end
        end
    end

    % Program = [['print' ['+' 4 5]]]
    Program = [['defvar' 'X']
               ['defvar' 'Y']
               ['defun' 'Fact' 'N'
                ['if' ['=' 'N' 0] 1
                 ['*' 'N' ['Fact' ['-' 'N' 1]]]]]
               ['defun' 'Xor' 'A' 'B'
                ['&' ['|' 'A' 'B']
                     ['!' ['&' 'A' 'B']]]]
               ['unify' 'X' ['Fact' 6]]
               ['print' 'X']
               ['print' ['!' 'false']]
               ['print' ['&' 'true' ['||' 'true' 'false']]]
               ['unify' 'Y' ['Xor' 'false' 'false']]
               ['print' 'Y']
               ['print' ['Xor' 'false' 'true']]
               ['-' ['+' 4 ['Fact' 3]]]]

    % Ctx = nil
    case {Eval Program nil} of Result|NewCtx|nil then
        {Show Result}
        {Show NewCtx}
    end

end