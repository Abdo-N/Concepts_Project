%I wrote these comments not AI I swear % me too 

:-consult('public_kb').

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
	
% --------------------------------------------------

check_staff(Day, Time, ReservationsList):-
	staff(Day, CountStaff),
	count_reservations(Day, Time, ReservationsList, 0, Result), 
	CountStaff >= Result.
	% makes sure total table amount of all reservations is less than staff count at a given day and time

% counts all the reservations in a list that are of Time and Day
count_reservations(_, _, [], Total, Total).
count_reservations(Day, Time, [res(Day, Time, GroupName, TableName)|T], Total, Result):-
	TotalNew is Total + 1,
	count_reservations(Day, Time, T, TotalNew, Result).
count_reservations(Day, Time, [res(DayNew, TimeNew, GroupName, TableName)|T], Total, Result):-
	(DayNew\=Day ; TimeNew\=Time), 
	count_reservations(Day, Time, T, Total, Result).
	
% --------------------------------------------------
	
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
    % 1. every reservation is valid
    forall(
        member(res(Day, Time, Group, Table), Schedule), %Checks each reservation made
        (
            member(Day, Days), %ensures that the reservation is in allowed day where there is staff 
            valid_reservation(res(Day, Time, Group, Table)) %The group exists,The table exists and has enough capacity,The group’s timing matches the reservation.
        )
    ),

    % 2. staff constraint
    forall(
        member(Day, Days),
        (
            staff(Day, StaffCount), %ensures that the reservation is in allowed day where there is staff
            count_reservations(Day, morning, Schedule, 0, MorningCount), 
            MorningCount =< StaffCount, %counts morning reservations and checks that the staff can handle it
            count_reservations(Day, evening, Schedule, 0, EveningCount),
            EveningCount =< StaffCount %counts evening reservations and checks that the staff can handle it
        )
    ),

    % 3. no duplicate reservations
    \+ (
        member(R, Schedule),
        select(R, Schedule, Rest),
        member(R, Rest)
    ).

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

% --------------------------------------------------

collect_ingredients([], []).

collect_ingredients([First | Rest], AllIngredients) :-
    recipe(First, Ings),          
    collect_ingredients(Rest, RestIngredients),  
    append(Ings, RestIngredients, AllIngredients).

group_ingredients(GroupName, Ingredients) :-
    order(GroupName, Dishes),    
    collect_ingredients(Dishes, Ingredients). 

% --------------------------------------------------

add_day_ingredients(Day, Ingredients, [(Day, Existing) | Rest], [(Day, Combined) | Rest]) :-
    append(Existing, Ingredients, Combined).

add_day_ingredients(Day, Ingredients, [Other | Rest], [Other | NewRest]) :-
    Other = (OtherDay, _), 
    OtherDay \= Day,
    add_day_ingredients(Day, Ingredients, Rest, NewRest).

add_day_ingredients(Day, Ingredients, [], [(Day, Ingredients)]). 

process_reservations([], Acc, Acc).

process_reservations([res(Day, Time, Group, Table) | Rest], Acc, Result) :-
    group_ingredients(Group, Ingredients),
    add_day_ingredients(Day, Ingredients, Acc, Acc1),
    process_reservations(Rest, Acc1, Result).

% allows AllIngredients to have any order, as long as each day's ingredients match
needed_ingredients(Reservations, AllIngredients) :-
    process_reservations(Reservations, [], Actual),  % generates full list of (Day, Ingredients)
    same_days_multiset(Actual, AllIngredients).      % compares with AllIngredients ignoring order

% Valid if Actual and Expected lists of (Day, Ingredients) are the same per day
%  1. each day must appear once in both lists
%  2. ingredients can be in any order for each day
same_days_multiset([], []). 
same_days_multiset([(Day, Ingredients)|Rest], Expected) :- 
    select((Day, ExpectedIngredients), Expected, Remaining), % finds ingredients for the same day
    same_multiset(Ingredients, ExpectedIngredients),           % checks that ingredients are the same regardless of order
    same_days_multiset(Rest, Remaining).                      % recursively checks remaining days

same_multiset([], []).  
same_multiset([H|T], L2) :-
    select(H, L2, L2Rest),  % remove one element (identical to H) from L2
    same_multiset(T, L2Rest).  
