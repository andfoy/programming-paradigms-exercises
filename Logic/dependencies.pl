:- dynamic installed/2.
:- dynamic package/2.
:- dynamic depends/5.

installed(numpy, [1, 15, 4]).
installed(pillow, [5, 2, 0]).
installed(six, [1, 11, 0]).
installed(future, [0, 17, 1]).
installed(pyyaml, [3, 13, 0]).
% installed(dependency, [0, 1, 1]).
% installed(torch, [1, 0, 0]).
% installed(opencv-python, [3, 4, 19]).

package(numpy, [1, 15, 5]).
package(numpy, [1, 15, 4]).
package(numpy, [1, 15, 1]).
package(numpy, [1, 14, 4]).
package(pillow, [5, 2, 0]).
package(six, [1, 11, 0]).
package(future, [0, 17, 1]).
package(pyyaml, [3, 13, 0]).
package(torch, [1, 0, 0]).
package(dep, [1, 0, 0]).
package(dep, [0, 0, 1]).
package(opencv-python, [3, 4, 19]).
package(torchvision, [0, 2, 1]).
package(dependency, [0, 2, 5]).

depends(torch, [1, 0, 0], numpy, [1, 15, 4], >=).
depends(torch, [1, 0, 0], future, [0, 17, 1], [*, *, *]).
depends(torch, [1, 0, 0], six, [1, 11, 0], [*, *, *]).
depends(torch, [1, 0, 0], pyyaml, [3, 13, 0], [*, *, *]).

depends(torchvision, [0, 2, 1], numpy, [1, 15, 4], [*, *, *]).
depends(torchvision, [0, 2, 1], pillow, [4, 1, 1], >=).
depends(torchvision, [0, 2, 1], six, [1, 11, 0], [*, *, *]).
depends(torchvision, [0, 2, 1], torch, [1, 0, 0], >=).
depends(torchvision, [0, 2, 1], dep, [1, 0, 0], >=).

depends(opencv-python, [3, 4, 19], dep, [0, 0, 1], \=).
depends(opencv-python, [3, 4, 19], numpy, [1, 15, 5], >=).
depends(opencv-python, [3, 4, 19], dependency, [0, 2, 1], [<, 0, 2, 3, "||", >, 0, 2, 5]).

zip([X], [Y], [[X,Y]]).
zip([X|L1], [Y|L2], [[X,Y]|L3]) :- zip(L1, L2, L3).


install(Package, Version) :-
    look_for_package(Package, Version),
    (not(installed(Package, Version)) ->
    % retractall(installed(Package, SomeVersion)),
    ((deps_versions(Package, Version, DepNames, DepVersions),
      maplist(install, DepNames, DepVersions)) -> install_single(Package, Version);
        (not(has_dependencies(Package, Version)), install_single(Package, Version)));
    format("Package ~w ~w is already installed ~n", [Package, Version])).

install_single(Package, Version) :-
    format("Installing package ~w ~w ~n", [Package, Version]),
    retractall(installed(Package, SomeVersion)),
    asserta(installed(Package, Version)).

deps_versions(Package, Version, DepNames, DepVersions) :-
    findall([Dep, DepVer], depends(Package, Version, Dep, _D, _F), L),
    zip(DepNames, DepVersions, L),
    maplist(install_p(Package, Version), DepNames, DepVersions), !.

install_p(Package, Version, Dependency, DepVersion) :-
    look_for_package(Package, Version),
    depends(Package, Version, Dependency, MinVersion, Flag),
    (find_dependency(Dependency, MinVersion, DepVersion, Flag) -> true; !, fail).

has_dependencies(Package, Version) :-
    depends(Package, Version, Dep, DepVersion, Flag), !.

look_for_package(Package, Version) :-
    (package(Package, Version) -> true;
     !, format("Could not find info for package ~w version ~w", [Package, Version]), fail).

find_dependency(Dependency, MinVersion, ValidVersion, Comparator) :-
    (installed(Dependency, InstalledVersion) ->
        look_and_validate(Dependency, MinVersion, InstalledVersion, ValidVersion, Comparator);
        (=(Comparator, =) ->
            ValidVersion = MinVersion;
            look_and_validate(Dependency, MinVersion, MinVersion, ValidVersion, Comparator))).

look_and_validate(Dependency, MinVersion, InstalledVersion, ValidVersion, Comparator) :-
    look_for_version(Dependency, MinVersion, InstalledVersion, ValidVersion, Comparator),
    foreach(depending_packages(Dependency, Package, Version, MinDepVersion, Flag),
            validate_version(Dependency, Package, Version, MinDepVersion,
                             ValidVersion, Flag, Comparator)).

look_for_version(Dependency, MinVersion, InstalledVersion, ToInstall, Flag) :-
    ((select_version(MinVersion, InstalledVersion, ValidVersion, Flag),
    package(Dependency, ValidVersion)) -> ToInstall = ValidVersion;
    ((package(Dependency, Version), select_version(MinVersion, Version, ToInstall, Flag)) -> !, true;
     !, format("There's no available version of package ~w that matches the flag ~w ~w", [Dependency, Flag, MinVersion]), fail)).


depending_packages(Dependency, Package,
                   PackVersion, MinInstalledVersion, Flag) :-
    installed(Package, PackVersion),
    depends(Package, PackVersion, Dependency, MinInstalledVersion, Flag).

validate_version(Dependency, Package, Version, MinDepVersion,
                 ToInstallVersion, Flag, PackFlag) :-
    select_version(MinDepVersion, ToInstallVersion, ToInstallVersion, Flag) -> !, true;
    !, format("Installed package ~w ~w requires dependency ~w ~w ~w, which is incompatible with required version ~w ~w",
              [Package, Version, Dependency, Flag, MinDepVersion, PackFlag, ToInstallVersion]), fail.

select_version([], [], [], Flag).
select_version(MinVersion, InstalledVersion, ToInstall, [Flag|Rest]) :-
    split_flags([Flag|Rest], SepFlags),
    (match_flags(InstalledVersion, SepFlags) -> ToInstall = InstalledVersion, !;
        (match_flags(MinVersion, SepFlags) -> ToInstall = MinVersion, !;
            !, fail)).

select_version(MinVersion, InstalledVersion, ToInstall, =) :-
    (MinVersion = InstalledVersion ->
        (!, ToInstall = InstalledVersion); !, fail).

select_version(MinVersion, InstalledVersion, ToInstall, \=) :-
    (not(MinVersion = InstalledVersion) ->
        (!, ToInstall = InstalledVersion); !, fail).

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

match_flags(Version, [or|[[First|[Second|More]]|Rest]]) :-
    (match_flags(Version, First) -> !, true;
        (match_flags(Version, Second) -> !, true;
            !, fail)).

match_flags(Version, [and|[[First|[Second|More]]|Rest]]) :-
    match_flags(Version, First), match_flags(Version, Second).

match_flags([Major|Minor], [*|Rest]) :-
    match_flags(Minor, Rest), !.

match_flags([Major|Minor], [Major|Rest]) :-
    match_flags(Minor, Rest), !.

match_flags(Version, [Op|CondVersion]) :-
    atom(Op),
    select_version(Version, CondVersion, Version, Op), !.

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