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
    add_ingredientslist(Handle,Ingredients),
    %recursively add the list of ingredients into the row
    ingredients_csv_HELPER(_,T,Handle).
    %continue on the rest

%base case we have one ingredient left so we add it then add a new line
add_ingredientslist([H|[]],Handle):- format(Handle, "~w~n", [H]).
add_ingredientslist([H|T], Handle):-
    format(Handle, "~w;", [H]),
    add_ingredientslist(T,Handle).

check_staff(Day, Time, ReservationsList):-
	valid_reservationslist(ReservationsList),
	staff(Day, CountStaff),
	count_reservations(Day, Time, ReservationsList, 0, Result), 
	CountStaff >= Result.
	% makes sure total table amount of all reservations is less than staff count at a given day and time

% counts all the reservations in a list that are of Time and Day
count_reservations(_, _, [], Total, Total).
count_reservations(Day, Time, [H|T], Total, Result):-
	H = res(Day, Time, GroupName, TableName),
	TotalNew is Total + 1,
	count_reservations(Day, Time, T, TotalNew, Result).
count_reservations(Day, Time, [H|T], Total, Result):-
	H = res(DayNew, TimeNew, GroupName, TableName),
	(DayNew\=Day ; TimeNew\=Time), 
	count_reservations(Day, Time, T, Total, Result).

% checks if all reservations in a list are valid
valid_reservationslist([]).
valid_reservationslist([H|T]):-
	valid_reservation(H),
	valid_reservationslist(T).

% checks if the given reservation is valid
% for a reservation to be valid: 
	% 1. the time of group arrival must be same as that of reservation
	% 2. the table assigned to the group at that time must have enough seats
valid_reservation(res(day(D,M), Time, GroupName, TableName)):-
	group(GroupName, CountMembers, Time), % time of group arrival must be same as that of reservation
	tables(TablesList), % provide list of available tables
	member(t(TableName, Capacity), TablesList),
	Capacity >= CountMembers. % enough seats available for group members

schedule_all_reservations(Days, Schedule):-
    all_groups(Groups),
    assign_groups(Groups,Days,[],Schedule).

% get all the groups that want reservations
all_groups(Groups):-
    findall(group(Name,Count,Timing),group(Name,Count,Timing),Groups).

% base case of assign_groups, were if the groups are empty then we have found the final schedule
assign_groups([],_,Schedule,Schedule).
% recursive call of assign_groups
assign_groups([group(Name,Count,Timing)| T],Days,Acc,Schedule):-
    member(Day,Days), % check that the Day is avaiable in the restaurants available Days 
    tables(TablesList),% returns the tables available in the restaurant 
    member(t(TableName, Capacity),TablesList), % returns the Table(s) that matches and returns the table name and Capacity
    Capacity >= Count, % makes sure that the capacity of the table is greater than or equal to the number of memebers 
    \+ member(res(Day, Timing, _, TableName), Acc), % checks that no reservations in Acc are made so no two groups are assigned the same table on the same day at the same time
    NewR = res(Day,Timing,Name,TableName), % makes the reservation for the group
    check_staff(Day,Timing,[NewR|Acc]), % checks the specific day and the time for the new reservation aligns with the staff avaliablity and capacity or not 
    assign_groups(T,Days,[NewR|Acc], Schedule).
