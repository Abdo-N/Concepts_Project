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

--Mariam
mostPopularDish :: [String] -> [String]
mostPopularDish [] = []
mostPopularDish list = maximumCount(map(\h -> (head h, length h)) (group (sort list)))

maximumCount :: [(String, Int)] -> [String]
maximumCount [] = []
maximumCount pairs = [name | (name, count) <- pairs, count == maximum [c | (_, c) <- pairs]]


countCategoryItems :: String -> Expense -> Int
countCategoryItems _ (Item _ _ _) = 0
countCategoryItems name (Category categoryName expenses) = if name == categoryName then countAllItems expenses
															                              else sum (map (countCategoryItems name) expenses)

countAllItems :: [Expense] -> Int
countAllItems expenses = sum (map countItem expenses)

countItem :: Expense -> Int
countItem (Item _ _ _) = 1
countItem (Category _ rest)  = countAllItems rest

--Sarah
summarizeAllDeliveries :: [Date] -> [Delivery]
summarizeAllDeliveries [] = []
summarizeAllDeliveries x = mergeByDates ( makeSupplyListandConvertBacktoMonth( sortByYearMonthDayIng( convertMonthandAddQuantity ( collectIngredients x) ) ) )

collectIngredients :: [Date] -> [(Date, (String, Price))]
collectIngredients [] = []
collectIngredients (date:t) = ( calculateDeliveryDates date ( flattenRecipies(findIngredients date shopping_list) ) ) ++ collectIngredients t

findIngredients :: Date -> [(Date, [Ingredient])] -> [Ingredient]
findIngredients _ [] = error "Date not found"
findIngredients date1 ((date2, ingredients):t) | date1==date2 = ingredients
											| otherwise = findIngredients date1 t
											
flattenRecipies :: [Ingredient] -> [Ingredient]
flattenRecipies [] = []
flattenRecipies (SimpleIngredient x:t) = (SimpleIngredient x):(flattenRecipies t)
flattenRecipies (Recipe x ingredients:t) = (flattenRecipies ingredients) ++ (flattenRecipies t)

convertMonthandAddQuantity :: [(Date, (String, Price))] -> [((Int,Int,Int), Supply)]
convertMonthandAddQuantity [] = []
convertMonthandAddQuantity (((day, month, year), (string, price)):t) | month == Jan = ((day, 1, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Feb = ((day, 2, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Mar = ((day, 3, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Apr = ((day, 4, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == May = ((day, 5, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Jun = ((day, 6, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Jul = ((day, 7, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Aug = ((day, 8, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Sep = ((day, 9, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Oct = ((day, 10, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Nov = ((day, 11, year), (string, 1, price)):convertMonthandAddQuantity t
													| month == Dec = ((day, 12, year), (string, 1, price)):convertMonthandAddQuantity t
													| otherwise = error "Not a month" 

sortByYearMonthDayIng :: [((Int,Int,Int), Supply)] -> [((Int,Int,Int), Supply)]
sortByYearMonthDayIng [] = []
sortByYearMonthDayIng (h:t) = insertAndMerge h (sortByYearMonthDayIng t) 

insertAndMerge :: ((Int,Int,Int), Supply) -> [((Int,Int,Int), Supply)] -> [((Int,Int,Int), Supply)]
insertAndMerge x [] = [x]
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

convertBacktoMonth :: [((Int,Int,Int), [Supply])] -> [(Date, [Supply])]	
convertBacktoMonth [] = []
convertBacktoMonth (((day, month, year), supply):t) | month == 1 = ((day, Jan, year), supply):convertBacktoMonth t
													| month == 2 = ((day, Feb, year), supply):convertBacktoMonth t
													| month == 3 = ((day, Mar, year), supply):convertBacktoMonth t
													| month == 4 = ((day, Apr, year), supply):convertBacktoMonth t
													| month == 5 = ((day, May, year), supply):convertBacktoMonth t
													| month == 6 = ((day, Jun, year), supply):convertBacktoMonth t
													| month == 7 = ((day, Jul, year), supply):convertBacktoMonth t
													| month == 8 = ((day, Aug, year), supply):convertBacktoMonth t
													| month == 9 = ((day, Sep, year), supply):convertBacktoMonth t
													| month == 10 = ((day, Oct, year), supply):convertBacktoMonth t
													| month == 11 = ((day, Nov, year), supply):convertBacktoMonth t
													| month == 12 = ((day, Dec, year), supply):convertBacktoMonth t
													| otherwise = error "Not a month" 														

convertSupplyList :: ((Int,Int,Int), Supply) -> ((Int,Int,Int), [Supply])
convertSupplyList (date, supply) = (date, [supply])

mergeByDates :: [Delivery] -> [Delivery]
mergeByDates [] = []
mergeByDates [x] = [x]
mergeByDates ((date1, supply1):(date2, supply2):t) | date1 == date2 = mergeByDates((date1, supply1++supply2):t)
													| otherwise = (date1, supply1):mergeByDates((date2, supply2):t)