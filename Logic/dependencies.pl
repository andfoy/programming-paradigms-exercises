% installed(torchvision, [0, 2, 1]).
:- dynamic installed/2.

installed(numpy, [1, 15, 4]).
installed(pillow, [5, 2, 0]).
installed(six, [1, 11, 0]).
installed(future, [0, 17, 1]).
installed(pyyaml, [3, 13, 0]).
installed(dependency, [0, 1, 1]).
% installed(torch, [1, 0, 0]).
installed(opencv-python, [3, 4, 19]).

package(torch, [1, 0, 0]).
package(numpy, [1, 15, 14]).


depends(torch, [1, 0, 0], numpy, [1, 15, 4], >=).
depends(torch, [1, 0, 0], future, [0, 17, 1], [*, *, *]).
depends(torch, [1, 0, 0], six, [1, 11, 0], [*, *, *]).
depends(torch, [1, 0, 0], pyyaml, [3, 13, 0], [*, *, *]).

depends(torchvision, [0, 2, 1], numpy, [1, 15, 4], [*, *, *]).
depends(torchvision, [0, 2, 1], pillow, [4, 1, 1], >=).
depends(torchvision, [0, 2, 1], six, [1, 11, 0], [*, *, *]).
depends(torchvision, [0, 2, 1], torch, [1, 0, 0], [*, *, *]).

depends(opencv-python, [3, 4, 19], numpy, [1, 14, 3], [*, *, 5]).
% depends(opencv-python, [3, 4, 19], dependency, [0, 2, 1], >=).

install_p(Package, Version, Dependency, DepVersion, Flag) :-
    depends(Package, Version, Dependency, MinVersion, Flag),
    (find_dependency(Dependency, MinVersion, DepVersion, Flag) -> true; !, fail).
    % install(Dependency, MinVersion, Flag),
    % asserta(installed, Package, Version).

find_dependency(Dependency, MinVersion, ValidVersion, Comparator) :-
    installed(Dependency, InstalledVersion) ->
        (select_version(MinVersion, InstalledVersion, ValidVersion, Comparator) -> true;
         !, format("Dependency "), fail),
        % not(depending_packages(Dependency, P, PV, IV, F)) -> !, ValidVersion = MinVersion;
        foreach(depending_packages(Dependency, Package, Version, MinDepVersion, Flag),
                validate_version(Dependency, Package, Version, MinDepVersion, ValidVersion, Flag));
            %    select_version(MinDepVersion, ValidVersion, ValidVersion, Flag));
    ValidVersion = MinVersion.

depending_packages(Dependency, Package,
                   PackVersion, MinInstalledVersion, Flag) :-
    installed(Package, PackVersion),
    depends(Package, PackVersion, Dependency, MinInstalledVersion, Flag).

validate_version(Dependency, Package, Version, MinDepVersion,
                 ToInstallVersion, Flag) :-
    select_version(MinDepVersion, ToInstallVersion, ToInstallVersion, Flag) -> !, true;
    !, format("Installed package ~w ~w requires dependency ~w ~w ~w, which is incompatible with required version ~w",
              [Package, Version, Dependency, Flag, MinDepVersion, ToInstallVersion]), fail.

select_version([], [], [], Flag).
select_version(MinVersion, InstalledVersion, ToInstall, [Flag|Rest]) :-
    split_flags([Flag|Rest], SepFlags),
    (match_flags(InstalledVersion, SepFlags) -> ToInstall = InstalledVersion, !;
        (match_flags(MinVersion, SepFlags) -> ToInstall = MinVersion, !;
            !, fail)).

select_version(MinVersion, InstalledVersion, ToInstall, =) :-
    (not(MinVersion = InstalledVersion) ->
        ToInstall = MinVersion, !;
        ToInstall = InstalledVersion, !).

select_version(MinVersion, InstalledVersion, ToInstall, \=) :-
    (MinVersion = InstalledVersion ->
        !, fail;
        ToInstall = InstalledVersion, !).

select_version(MinVersion, InstalledVersion, ToInstall, ^) :-
    select_version(MinVersion, InstalledVersion, ToInstall, >=), !.

select_version(MinVersion, InstalledVersion, ToInstall, ~) :-
    select_version(MinVersion, InstalledVersion, ToInstall, >=), !.

select_version([MinNumber|MinVersion],
               [InstalledNumber|InstalledVersion], ToInstall, Comp) :-
    not(=(Comp, ^)),
    not(=(Comp, ~)),
    not(=(Comp, *)),
    (InstalledNumber =:= MinNumber ->
        select_version(MinVersion, InstalledVersion, More, Comp),
        append([MinNumber], More, ToInstall), !;
    (call(Comp, MinNumber, InstalledNumber) ->
        ToInstall = [MinNumber|MinVersion], !;
        ToInstall = [InstalledNumber|InstalledVersion], !)).


match_flags([], []).

match_flags(Version, [or|[[First|Second]|Rest]]) :-
    (match_flags(Version, First) -> !, true;
        (match_flags(Version, Second) -> !, true;
            !, fail)).

match_flags(Version, [and|[[First|Second]|Rest]]) :-
    match_flags(Version, First), match_flags(Version, Second).

match_flags([Major|Minor], [*|Rest]) :-
    match_flags(Minor, Rest), !.

match_flags([Major|Minor], [Major|Rest]) :-
    match_flags(Minor, Rest), !.

match_flags(Version, [Op|CondVersion]) :-
    atom(Op),
    select_version(CondVersion, Version, Version, Op), !.

split_flags(Flags, SepFlags) :-
    split_flags(Flags, [SepFlags|Discard], []), !.

split_flags([], SepFlags, Accum) :-
    SepFlags = [Accum], !.
split_flags([","|Rest], SepFlags, Accum) :-
    split_flags(Rest, NewSepFlags, []),
    InterFlags = [Accum|NewSepFlags],
    SepFlags= [[and|[InterFlags]]], !.
split_flags(["||"|Rest], SepFlags, Accum) :-
    split_flags(Rest, NewSepFlags, []),
    InterFlags = [Accum|NewSepFlags],
    SepFlags= [[or|[InterFlags]]], !.
split_flags([Flag|Rest], SepFlags, Accum) :-
    append(Accum, [Flag], CurrentAccum),
    % CurrentAccum = [Flag|Accum],
    split_flags(Rest, SepFlags, CurrentAccum), !.