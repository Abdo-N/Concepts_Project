%group(Name, Count, Timing) %indicates a single group that want to make a reservation. The group's name is Name and the number of members is Count, their preferred timing is Timing. Timing can be one of two constants: morning ,evening. A single group must all be seated together at the same table.
group(a, 1, morning). 
group(b, 4, evening). 
group(c, 3, morning). 
group(d, 2, evening).

%staff(Day, Count) %indicates there is a number Count of staff members available on Day. Staff members available on a specific day are there for both morning and evening. Day is represented as a structure day(Day, Month) where Day and Month are both numbers.
staff(day(15, 2), 1). %staff available on each day staff(day(Day, Month), Number). staff available on a given day are present for both morning and evening timings.
staff(day(17, 2), 5).
staff(day(16, 2), 2).

% tables(Tables) %provides a list of Tables available in the restaurant. 
tables([t(t1, 2),t(t2, 4),t(t3, 1)]). %list of tables in the restaurant and their capacities. Each table is represented as a structure t(TableName, Capacity)

%recipe(DishName, Ingredients) %provides a list of Ingredients that are needed to cook DishName
recipe(soup, [ing1, ing2, ing3]).
recipe(salad, [ing1, ing3, ing4, ing5]).
recipe(cake, [ing5,ing6]).

% order(GroupName, DishNames) %provides the list of DishNames that are ordered by  specific GroupName
order(a, [soup]).
order(b, [cake, cake, cake, cake]).
order(c, [cake, soup, salad]).
order(d, [salad, soup]).


group(a, 1, morning).
group(b, 1, evening).
group(c, 2, morning).
group(d, 5, evening).
group(e, 8, morning).
group(f, 10, evening).
group(g, 3, morning).
group(h, 3, morning).
group(i, 4, evening).
group(j, 4, evening).

% Staff availability 
staff(day(1, 3), 4).   
staff(day(2, 3), 2).   
staff(day(3, 3), 1).   
staff(day(4, 3), 3).   

% Tables
tables([
    t(small, 2),
    t(medium, 4),
    t(large, 6),
    t(xlarge, 10)
]).



% Recipes
recipe(pasta, [flour, eggs, salt]).
recipe(pizza, [flour, tomato, cheese, basil]).
recipe(salad, [lettuce, tomato, cucumber, olive_oil]).
recipe(burger, [beef, bun, lettuce, tomato, cheese]).
recipe(soup, [broth, vegetables, salt]).
recipe(steak, [beef, butter, garlic]).
recipe(fish, [salmon, lemon, herbs]).
recipe(dessert, [sugar, flour, eggs, chocolate]).

% Orders
order(a, [pasta]).
order(b, [pizza, salad]).
order(c, [pasta, pasta]).
order(d, [pizza, pizza, pasta, salad, dessert]).
order(e, [steak, steak, fish, fish, salad, salad, soup, dessert]).
order(f, [pizza, pizza, pizza, burger, burger, salad, salad, pasta, soup, dessert]).
order(g, [pasta, salad]).
order(h, [pizza, salad]).
order(i, [soup, soup]).
order(j, [fish, steak]).























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

schedule_all_reservations(Days, Schedule):- %!!!!!!!!!!!!!!!!
    all_groups(Groups),
    assign_groups(Groups,Days,[],Schedule).

% get all the groups that want reservations
all_groups(Groups):-
    findall(group(Name,Count,Timing),group(Name,Count,Timing),Groups).

% base case of assign_groups, were if the groups are empty then we have found the final schedule
assign_groups([],_,Schedule,Schedule).
% recursive call of assign_groups
assign_groups([group(Name,Count,Timing)| T],[Day|Days],Acc,Schedule):-
    %member(Day,Days), % check that the Day is avaiable in the restaurants available Days 
    tables(TablesList),% returns the tables available in the restaurant 
    member(t(TableName, Capacity),TablesList), % returns the Table(s) that matches and returns the table name and Capacity
    Capacity >= Count, % makes sure that the capacity of the table is greater than or equal to the number of memebers 
    \+ member(res(Day, Timing, _, TableName), Acc), % checks that no reservations in Acc are made so no two groups are assigned the same table on the same day at the same time
    NewR = res(Day,Timing,Name,TableName), % makes the reservation for the group
    check_staff(Day,Timing,[NewR|Acc]), % checks the specific day and the time for the new reservation aligns with the staff avaliablity and capacity or not 
    assign_groups(T,Days,[NewR|Acc], Schedule).




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

needed_ingredients(Reservations, AllIngredients) :-
    process_reservations(Reservations, [], AllIngredients).
