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
	
%Generates if Schedule is unbound
%Validates if Schedule is provided
schedule_all_reservations(Days, Schedule) :-
    var(Schedule), %checks if Schedule is assigned smth or not 
    generate_schedule(Days, Schedule).%Schedule is a variable so need to generate a schedule
schedule_all_reservations(Days, Schedule) :-
    nonvar(Schedule),%checks if Schedule is assigned smth or not 
    validate_schedule(Days, Schedule). %Schedule is not a variable so need to validate if the schedule is correct or not  
generate_schedule(Days, Schedule) :-
    all_groups(Groups),%returns all that is in the knowledge base
    sort_groups_by_size(Groups, SortedGroups), %assigns the bigger group first so there will be more tables for small ones
    assign_groups(SortedGroups, Days, [], ScheduleUnsorted),%it assigns each group a table 
    reverse(ScheduleUnsorted, Schedule). %reverses the Schedule in the same order so that the backtracking doesnt affect the outcome

validate_schedule(Days, Schedule) :-
    forall(member(res(Day, Time, Group, Table), Schedule),%Checks each reservation made
	( member(Day, Days), %ensures that the reservation is in allowed day where there is staff 
	valid_reservation(res(Day, Time, Group, Table)))), %The group exists,The table exists and has enough capacity,The group’s timing matches the reservation.
	forall(member(Day, Days)%ensures that the reservation is in allowed day where there is staff ,
	( staff(Day, StaffCount),%checks the available staff from the knowledege base
	count_reservations(Day, morning, Schedule, 0, MorningCount), MorningCount =< StaffCount, %counts morning reservations and checks that the staff can handle it 
	count_reservations(Day, evening, Schedule, 0, EveningCount), EveningCount =< StaffCount)),%counts evening reservations and checks that the staff can handle it
    forall(member(res(Day, Time, _, TableName), Schedule),,%Checks each reservation made in Schedule
	\+ (member(res(Day, Time, _, TableName), Schedule,%Checks each reservation made isnt in Schedule
           \+ member(res(Day, Time, _, TableName), Schedule))).%Checks each reservation made isnt in Schedule

% base case of assign_groups, were if the groups are empty then we have found the final schedule
assign_groups([], _, Acc, Acc).

%recursive call of assign_groups
assign_groups([group(Name, Count, Timing)|Rest], Days, Acc, Schedule) :-
    member(Day, Days), % check that the Day is avaiable in the restaurants available Days 
    staff(Day, StaffCount),
    count_reservations(Day, Timing, Acc, 0, CurrentCount),
    CurrentCount < StaffCount,
    tables(TablesList),
    include(tablecheck(Day, Timing, Acc, Count), TablesList, AvailableTables),
    AvailableTables \= [],
    member(t(TableName, _), AvailableTables),
    NewRes = res(Day, Timing, Name, TableName),
    valid_reservation(NewRes),
    NewAcc = [NewRes|Acc],
    assign_groups(Rest, Days, NewAcc, Schedule).

% Table availability check
tablecheck(Day, Timing, Acc, Count, t(TableName, Capacity)) :-
    Capacity >= Count,
    \+ member(res(Day, Timing, _, TableName), Acc).
% Reservation validation
valid_reservation(res(day(D,M), Time, GroupName, TableName)) :-
    group(GroupName, CountMembers, Time),
    tables(TablesList),
    member(t(TableName, Capacity), TablesList),
    Capacity >= CountMembers.

all_groups(Groups) :-
    findall(group(Name, Count, Timing), group(Name, Count, Timing), Groups).

sort_groups_by_size(Groups, Sorted) :-
    map_list_to_pairs(get_group_size, Groups, Pairs),
    keysort(Pairs, SortedPairsAsc),
    reverse(SortedPairsAsc, SortedPairsDesc),
    pairs_values(SortedPairsDesc, Sorted).

get_group_size(group(_, Count, _), Count).



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
