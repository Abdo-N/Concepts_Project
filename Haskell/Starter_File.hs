data Month = Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec   deriving (Show, Eq)

type Date = (Int, Month, Int)
type Price = Float
type Quantity = Int

type Supply = (String, Quantity, Price)
--	representing the name of the ingredient, quantity needed of that ingredient, and the total price of the needed quantity

type Delivery = (Date, [Supply]) 
-- date of delivery the restaurant will make and the required supply on that date.
 

data Ingredient = 
    SimpleIngredient String  -- A basic ingredient
  | Recipe String [Ingredient] deriving (Show, Eq) 
  -- An ingredient consisting of other ingredients


data Expense = 
    Item String Price Date              
    -- A single expense item
  | Category String [Expense]     
  -- A category of expenses that could contain expenses or other categories.
  deriving (Show, Eq)
    

ingredient_info :: [(String, Int, Price)]
ingredient_info = [("rice", 20, 1.2), ("apples", 5, 5), ("flour", 1, 0.5), ("eggs",1, 2), ("butter", 3, 12), ("garlic", 11, 4.5), ("salt", 0,0.25), ("pepper", 66,0.75), ("sugar", 7, 6), ("goat_meat", 20, 1.2)]

shopping_list :: [(Date, [Ingredient])]
shopping_list = [((15,Feb,2026),
                    [SimpleIngredient "flour",
                     SimpleIngredient "eggs",
                     SimpleIngredient "rice"]),
                 ((17,Feb,2026),
                    [SimpleIngredient "sugar",
                     SimpleIngredient "butter",
                     SimpleIngredient "flour",
                     SimpleIngredient "flour",
                     (Recipe "dough" [(SimpleIngredient "flour"),
                                      (SimpleIngredient "eggs")])]),
                 ((5,Mar,2026),
                    [SimpleIngredient "salt",
                     SimpleIngredient "pepper",
                     SimpleIngredient "garlic"]) ]
-- Do not submit any code above this line
-- Do not move any data below this line
-- ////////////////////////////////////////////////////////////////////////////////

-- Start your code here

--Nader----------

--handling if in case we subtract Feb 5 minus 10 days so we spill to jan
prevMonth :: Month -> Month
prevMonth Jan = Dec
prevMonth Feb = Jan
prevMonth Mar = Feb
prevMonth Apr = Mar
prevMonth May = Apr
prevMonth Jun = May
prevMonth Jul = Jun
prevMonth Aug = Jul
prevMonth Sep = Aug
prevMonth Oct = Sep
prevMonth Nov = Oct
prevMonth Dec = Nov

daysInMonth :: Month -> Int
daysInMonth m
    | m `elem` [Jan, Mar, May, Jul, Aug, Oct, Dec] = 31
    | m == Feb = 28
    | otherwise = 30

--helper to subtract days
subtractDays :: Date -> Int -> Date
subtractDays (day, month, year) daysToSubtract 
  | daysToSubtract >= day = subtractDays (daysInMonth newMonth, newMonth, newYear)(daysToSubtract - day)
  | otherwise = (day - daysToSubtract, month, year)
  where
    newMonth = prevMonth month
    newYear = if month == Jan then year - 1 else year

-- Helper to look for ingredient and return their 
lookupIngredient :: String -> [(String, Int, Price)] -> (Int, Price)
lookupIngredient x [] = error "Ingredient not found"
lookupIngredient x ((name, daysToDeliver, price):t)
    | x == name = (daysToDeliver, price)
    | otherwise = lookupIngredient x t

calculateDeliveryDates :: Date -> [Ingredient] -> [(Date, (String, Price))]
calculateDeliveryDates _ [] = []
calculateDeliveryDates date (SimpleIngredient x:t) = (deliveryDate, (x, price)) : calculateDeliveryDates date t
    where
    (days, price) = lookupIngredient x ingredient_info
    deliveryDate  = subtractDays date days
calculateDeliveryDates date (Recipe x ingredients:t) = calculateDeliveryDates date ingredients ++ calculateDeliveryDates date t

--Sarah----------
summarizeAllDeliveries :: [Date] -> [Delivery]
summarizeAllDeliveries [] = []
summarizeAllDeliveries x = mergeByDates ( makeSupplyListandConvertBacktoMonth( sortByYearMonthDayIng( convertMonthandAddQuantity ( collectIngredients x) ) ) )

-- Finds ingredients for each date from shopping list (recipies are flattened so everything is a simple ingredient) and generates a list of needed ingredients
-- Finds delivery date for each ingredient in said list
collectIngredients :: [Date] -> [(Date, (String, Price))]
collectIngredients [] = []
collectIngredients (date:t) = ( calculateDeliveryDates date ( flattenRecipies(findIngredients date shopping_list) ) ) ++ collectIngredients t

-- When the user enters shopping list in the query, findIngredients recurses over it to get the correct ingredients list based on date
findIngredients :: Date -> [(Date, [Ingredient])] -> [Ingredient]
findIngredients _ [] = error "Date not found"
findIngredients date1 ((date2, ingredients):t) | date1==date2 = ingredients
											| otherwise = findIngredients date1 t
											
flattenRecipies :: [Ingredient] -> [Ingredient]
flattenRecipies [] = []
flattenRecipies (SimpleIngredient x:t) = (SimpleIngredient x):(flattenRecipies t)
flattenRecipies (Recipe x ingredients:t) = (flattenRecipies ingredients) ++ (flattenRecipies t) -- don't forget to flatten tail also in case there are more recipies

monthToInt :: Month -> Int
monthToInt Jan = 1
monthToInt Feb = 2
monthToInt Mar = 3
monthToInt Apr = 4
monthToInt May = 5
monthToInt Jun = 6
monthToInt Jul = 7
monthToInt Aug = 8
monthToInt Sep = 9
monthToInt Oct = 10
monthToInt Nov = 11
monthToInt Dec = 12

-- Converts english months to numbers for each ingredient and adds its supply quantity (initially there's only one of each)
convertMonthandAddQuantity :: [(Date, (String, Price))] -> [((Int,Int,Int), Supply)]
convertMonthandAddQuantity [] = []
convertMonthandAddQuantity (((day, month, year), (string, price)):t) = ((day, (monthToInt month), year), (string, 1, price)):convertMonthandAddQuantity t

-- Basically insertion sort, goes through all cases of sorting from highest to least priority (year then month then day then string/name of ingredient)
sortByYearMonthDayIng :: [((Int,Int,Int), Supply)] -> [((Int,Int,Int), Supply)]
sortByYearMonthDayIng [] = []
sortByYearMonthDayIng (h:t) = insertAndMerge h (sortByYearMonthDayIng t) 

-- insertion by priority + condenses same name ingredients of the same date into one listing with a combined amount and price
insertAndMerge :: ((Int,Int,Int), Supply) -> [((Int,Int,Int), Supply)] -> [((Int,Int,Int), Supply)]
insertAndMerge x [] = [x] 
-- compares heads together, if h1<h2 we put it before h2 and that's it, but if h1>h2 then we put h2 first and recurse to insert h1 in the right place in the tail
insertAndMerge ((day1, month1, year1), (string1, amount1, price1)) (((day2, month2, year2), (string2, amount2, price2)):t) | year1 < year2 = ((day1, month1, year1), (string1, amount1, price1)):((day2, month2, year2), (string2, amount2, price2)):t
																									| year1 == year2 && month1 < month2 = ((day1, month1, year1), (string1, amount1, price1)):((day2, month2, year2), (string2, amount2, price2)):t
																									| year1 == year2 && month1 == month2 && day1 < day2 = ((day1, month1, year1), (string1, amount1, price1)):((day2, month2, year2), (string2, amount2, price2)):t
																									| year1 == year2 && month1 == month2 && day1 == day2 && string1 < string2 = ((day1, month1, year1), (string1, amount1, price1)):((day2, month2, year2), (string2, amount2, price2)):t
																									| year1 == year2 && month1 == month2 && day1 == day2 && string1 == string2 = ((day1, month1, year1), (string1, (amount1+amount2), (price1+price2))):t
																									| year1 == year2 && month1 == month2 && day1 == day2 && string1 > string2 = ((day2, month2, year2), (string2, amount2, price2)): (insertAndMerge ((day1, month1, year1), (string1, amount1, price1)) t)
																									| year1 == year2 && month1 == month2 && day1 > day2 = ((day2, month2, year2), (string2, amount2, price2)): (insertAndMerge ((day1, month1, year1), (string1, amount1, price1)) t)
																									| year1 == year2 && month1 > month2 = ((day2, month2, year2), (string2, amount2, price2)): (insertAndMerge ((day1, month1, year1), (string1, amount1, price1)) t)
																									| year1 > year2 = ((day2, month2, year2), (string2, amount2, price2)): (insertAndMerge ((day1, month1, year1), (string1, amount1, price1)) t)
																									| otherwise = error "Error in insertAndMerge"

																									
makeSupplyListandConvertBacktoMonth :: [((Int,Int,Int), Supply)] -> [Delivery]																								
makeSupplyListandConvertBacktoMonth x = convertBacktoMonth(map convertSupplyList x)

intToMonth :: Int -> Month
intToMonth 1 = Jan
intToMonth 2 = Feb
intToMonth 3 = Mar
intToMonth 4 = Apr
intToMonth 5 = May
intToMonth 6 = Jun
intToMonth 7 = Jul
intToMonth 8 = Aug
intToMonth 9 = Sep
intToMonth 10 = Oct
intToMonth 11 = Nov
intToMonth 12 = Dec

convertBacktoMonth :: [((Int,Int,Int), [Supply])] -> [(Date, [Supply])]	
convertBacktoMonth [] = []
convertBacktoMonth (((day, month, year), supply):t) = ((day, (intToMonth month), year), supply):convertBacktoMonth t	
												
-- takes each supply "item" (because at this point there's only one of each type of ingredient) and puts it in a list to prep for merging items in the same list later
convertSupplyList :: ((Int,Int,Int), Supply) -> ((Int,Int,Int), [Supply])
convertSupplyList (date, supply) = (date, [supply])

-- takes a list of tuples of ingredients and their delivery dates then puts those of the same date together in one supply while maintaining their alphabetical order
mergeByDates :: [Delivery] -> [Delivery]
mergeByDates [] = []
mergeByDates [x] = [x]
mergeByDates ((date1, supply1):(date2, supply2):t) | date1 == date2 = mergeByDates((date1, supply1++supply2):t)
													| otherwise = (date1, supply1):mergeByDates((date2, supply2):t)

--Abdelrahman Sameh 

-- Main function: takes deliveries, returns one big Expense
getDeliveryExpenses :: [Delivery] -> Expense
getDeliveryExpenses deliveries = 
   Category "Food Supplies" (flattenDeliveries deliveries)

-- Helper: flatten deliveries
flattenDeliveries :: [Delivery] -> [Expense]
flattenDeliveries [] = []
flattenDeliveries ((date, supplies):rest) = 
  deliveryToItems (date, supplies) ++ flattenDeliveries rest

-- Helper 1: Convert one delivery to a list of items
deliveryToItems :: Delivery -> [Expense]
deliveryToItems (date, []) =  []
deliveryToItems (date, (name, qty, price):supplies) = 
  Item name price date : deliveryToItems (date, supplies)


-- Helper 2: Convert one supply to ONE item
supplyToItem :: Date -> Supply -> Expense
supplyToItem date (name, qty, price) = 
  Item name price date 


-- calculateTotalExpenses

calculateTotalExpenses :: Expense -> Price
calculateTotalExpenses (Item _ price _) =
 price
 
calculateTotalExpenses (Category _ children) = 
 sum (map calculateTotalExpenses children)

--Mariam----------
mostPopularDish :: [String] -> [String]
mostPopularDish [] = []
mostPopularDish list = maximumCount(map(\h -> (head h, length h)) (group1 (sort list)))

group1 :: Eq a => [a] -> [[a]]
group1 [] = []
group1 (x:xs) = groupHelper x xs [x]

groupHelper :: Eq a => a -> [a] -> [a] -> [[a]]
groupHelper _ [] acc = [acc]
groupHelper prev (y:ys) acc = if prev == y then groupHelper y ys (acc ++ [y])
								else acc : groupHelper y ys [y]

insert :: Ord a => a -> [a] -> [a]
insert x [] = [x]
insert x (y:ys) | x < y = x:y:ys
				|otherwise = y:insert x ys

sort :: Ord a => [a] -> [a]
sort [] = []
sort (x:xs) = insert x (sort xs)


maximumCount :: [(String, Int)] -> [String]
maximumCount [] = []
maximumCount pairs = [name | (name, count) <- pairs, count ==maximum [c | (_, c) <- pairs]]


countCategoryItems :: String -> Expense -> Int
countCategoryItems _ (Item _ _ _) = 0
countCategoryItems name (Category categoryName expenses) = if name == categoryName then countAllItems expenses
															else sum (map (countCategoryItems name) expenses)

countAllItems :: [Expense] -> Int
countAllItems expenses = sum (map countItem expenses)

countItem :: Expense -> Int
countItem (Item _ _ _)           = 1
countItem (Category _ rest)  = countAllItems  rest
