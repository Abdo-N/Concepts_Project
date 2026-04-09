%I wrote these comments not AI I swear % me too 

write_reservations_to_csv(Filename, Schedule):- %Jumpstart
    open(Filename, write, Handle), %Open the file for the first time
    reservation_csv_HELPER(Filename,Schedule,Handle). %Call helper
    %Handle is a refernce to the file for prolog to use

%Base case just close the file
reservation_csv_HELPER(_,[], Handle):- 
    close(Handle).

%Recursivly loop through res(...) data structure and add to CSV file
reservation_csv_HELPER(_, [res(day(D, M), Time, Group, Table)|T], Handle):-
    format(Handle, "~w,~w,~w,~w,~w~n",[D,M,Time,Group,Table]),
    %this format predicate handles writing multiple things with commas
    reservation_csv_HELPER(_,T,Handle).
    %continue recursing
    

write_ingredients_to_csv(Filename, AllIngredients):- %Jumpstart
   
   open(Filename, write, Handle),
    ingredients_csv_HELPER(Filename, AllIngredients, Handle).

ingredients_csv_HELPER(_,[], Handle):- %Base case
    close(Handle).

ingredients_csv_HELPER(_, [(day(D,M), Ingredients)|T], Handle):-
    format(Handle, "~w,~w,",[D,M]),
    %add the day and month first
    add_ingredientslist(Ingredients,Handle),
    %recursively add the list of ingredients into the row
    ingredients_csv_HELPER(_,T,Handle).
    %continue on the rest

%base case we have one ingredient left so we add it then add a new line
add_ingredientslist([H|[]],Handle):- format(Handle, "~w~n", [H]).
add_ingredientslist([H|T], Handle):-
    format(Handle, "~w;", [H]),
    add_ingredientslist(T,Handle).

check_staff(Day, Time, ReservationsList):-
	staff(Day, CountStaff),
	count_reservations(Day, Time, ReservationsList, 0, Result), 
	CountStaff >= Result.
	% makes sure total table amount of all reservations is less than staff count at a given day and time

% base case
count_reservations(_, _, [], Total, Total).

% matches day and time
count_reservations(Day, Time, [res(Day, Time, _, _) | T], Acc, Result) :-
    NewAcc is Acc + 1,
    count_reservations(Day, Time, T, NewAcc, Result).

% does NOT match day or time
count_reservations(Day, Time, [res(D, Tm, _, _) | T], Acc, Result) :-
    (D \= Day ; Tm \= Time),
    count_reservations(Day, Time, T, Acc, Result).
	
schedule_all_reservations(Days, Schedule) :-
    all_groups(Groups),
    assign_groups(Groups, Days, [], Schedule).

all_groups(Groups) :- 
    findall(group(Name, Count, Timing), group(Name, Count, Timing), Groups).

% Base case: all groups assigned
assign_groups([], _, Acc, Schedule) :- 
    reverse(Acc, Schedule).

assign_groups(Groups, Days, Acc, Schedule) :-
    select(group(Name, Count, Timing), Groups, RemainingGroups),
    member(Day, Days),
    tables(TablesList),
    include(free_table(Day, Timing, Acc, Count), TablesList, AvailableTables),
    member(t(TableName, _), AvailableTables),
    NewAcc = [res(Day, Timing, Name, TableName)|Acc],
    check_staff(Day, Timing, NewAcc),
    assign_groups(RemainingGroups, Days, NewAcc, Schedule).

free_table(Day, Timing, Acc, Count, t(TableName, Capacity)) :-
    Capacity >= Count,
    \+ member(res(Day, Timing, _, TableName), Acc).


collect_ingredients([], []).

collect_ingredients([First | Rest], AllIngredients) :-
    recipe(First, Ings),          
    collect_ingredients(Rest, RestIngredients),  
    append(Ings, RestIngredients, AllIngredients).

group_ingredients(GroupName, Ingredients) :-
    order(GroupName, Dishes),    
    collect_ingredients(Dishes, Ingredients). 


add_day_ingredients(Day, Ingredients, [(Day, Existing) | Rest], [(Day, Combined) | Rest]) :-
    append(Existing, Ingredients, Combined).

add_day_ingredients(Day, Ingredients, [Other | Rest], [Other | NewRest]) :-
    Other = (OtherDay, _), 
    OtherDay \= Day,
    add_day_ingredients(Day, Ingredients, Rest, NewRest).

add_day_ingredients(Day, Ingredients, [], [(Day, Ingredients)]). 

process_reservations([], Acc, Acc).

process_reservations([res(Day, _, Group, _) | Rest], Acc, Result) :-
    group_ingredients(Group, Ingredients),
    add_day_ingredients(Day, Ingredients, Acc, Acc1),
    process_reservations(Rest, Acc1, Result).

	
% Main predicate: needed_ingredients/2
% Computes the ingredients needed for a list of reservations.
% It allows AllIngredients to have any order, as long as each day's ingredients match.
needed_ingredients(Reservations, AllIngredients) :-
    process_reservations(Reservations, [], Actual),  % Step 1: generate the full list of (Day, Ingredients)
    same_days_multiset(Actual, AllIngredients).      % Step 2: compare with AllIngredients ignoring order

% same_days_multiset(+Actual, +Expected)
% True if Actual and Expected lists of (Day, Ingredients) are "equivalent" per day
%  - each day must appear once in both lists
%  - ingredients can be in any order (multiset comparison)
same_days_multiset([], []).  % Base case: both lists empty
same_days_multiset([(Day, Ingredients)|Rest], Expected) :- 
    select((Day, ExpectedIngredients), Expected, Remaining), % find the matching day in Expected
    same_multiset(Ingredients, ExpectedIngredients),           % check that ingredients match as a multiset
    same_days_multiset(Rest, Remaining).                      % recursively check remaining days

% same_multiset(+List1, +List2)
% True if List1 and List2 contain the same elements (including duplicates), order doesn't matter
same_multiset([], []).      % Base case: both empty
same_multiset([H|T], L2) :-
    select(H, L2, L2Rest),  % remove one occurrence of H from L2
    same_multiset(T, L2Rest).  % recursively check remaining elements
