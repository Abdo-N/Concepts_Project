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



