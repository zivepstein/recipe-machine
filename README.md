# recipe-machine
First, the key file is the Excel called "Grocery List." There are four sheets in them:

(1) Section_guide

Just needs to be completed once; this determines the sort order for the items based on the structure of the store (so e.g. if you walk into your grocery store and the the first thing you encounter is the bread, you'd have a "section" in column A called "bread," and then a 1. When exporting the list of grocery items, the code sorts on this variable so you can make this designation as fine or coarse as you want.

(2) Recipe_list

Here is where you enter your full list of recipes, and "order" things each week.

Column A, "recipe", is the name you assign each food item. It needs to be a single word in a coding sense; Stata will at one point use these as variable names.

Column C, "making" is where you indicate the amount you want. When deciding what to buy for the week you then will put numbers representing the amount of each thing you want (so e.g. if you want to make two patches of roasted asparagus, you could indicate 2 to double the order).

None of the other columns are kept in the export, so you can e.g. offer a description of the thing "makes 6 tacos", additional points "often made with the red salsa, etc" or whatever else you want.

(3) food_in_recipes

This is the key sheet, that we update whenever we add recipes, that indicates for each recipe, the ingredients used in it. There are two strategies you might reasonably employ, one is to go to town some afternoon entering a bunch of recipes, or two just add a recipe whenever you make something novel--we basically just do strategy 2. 

Column A, "food_item", is the ingredient. (Probably possible to just start with ours and adapt, but obviously you could also start over). Column B, tjs_section, is where in the store the item is located. This should be an exact match with the sections in your Section_guide sheet. Column C, "buy", is a variable for whether it's something you'll always need to buy whenever you go shopping (eg a bell pepper) or something you'll only sometimes need to buy (e.g. salt). This matters just in that the Stata code exports based on this distinction, to make it easier to check which items in your house you already have (I originally had a "sometimes" vs "rarely" distinction that you'll see in the file, but we've discovered this isn't actually very useful, and so now just code everything as either sometimes or always).

Column D, "house_place" is the section in your house where you keep your items--you could actually just ignore this column and it'll export randomly, but we use it so that when we're checking what we already have, we can check all the items in the fridge before checking the pantry before checking the spice rack.

Then, starting in Column E is where we input all of the recipes. The top row we paste in the recipe name from the recipe_list sheet (needs to be an exact match, I just copy and paste in) and then in each row, the items that are part of the recipe. I generally use ctrl+F to find the items as I'm going through a novel recipe, and hide every column except for the one I'm currently adding to.

(4) Misc_food

Then finally, for things you want that are not part of recipes (breakfast, snacks, etc), there's a final sheet called misc_food. This is more straightforward, add any items, their section in the grocery store, and the quantity you want.

Running the code, exporting
 
In practice, our flow for making a grocery list is (a) deciding what we want of any existing items, (b) adding a new recipe if we're making something novel, (c) adding the misc items for the week. Then once we've done so, we save the Excel, and run the do-file, "create_shopping_list." You'll have to update the directories the first time you run it, but then after that, basically you just run the do-file, and it'll export a "List - Zivvy" file that has your grocery list for the week.

When you open the Excel, it's sorted by (a) items separated by the "always buy" (at the top), and then sometimes (ie, to check, at the bottom), then (b) among the "sometimes buy", they'll be sorted by the part of your house. You can check that, and delete whatever you have already. Then finally, the last step is to sort the Excel by Column C, TJs_sort, and it'll sort by the section of the grocery store.
