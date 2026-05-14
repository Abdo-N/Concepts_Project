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