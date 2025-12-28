public inherited sharing class RecipeController {
    @AuraEnabled(Cacheable=true)
    public static List<Recipe__c> getAllRecipes() {
        return [
            SELECT
                Id,
                Name,
                Draft__c,
                Active_Time__c,
                Active_Time_Units__c,
                Complexity__c,
                Needs_Review__c,
                Possible_Duplicate__c,
                Season__c
            FROM Recipe__c
            ORDER BY Name
            LIMIT 50
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static List<Recipe__c> searchRecipes(String searchTerm) {
        List<Recipe__c> recipes = new List<Recipe__c>();

        // Return all recipes when no search term
        searchTerm = searchTerm.trim();
        if (searchTerm == '') {
            recipes = getAllRecipes();
        } else {
            // Prepare query parameters
            searchTerm = '%' + searchTerm + '%';

            // Execute search query
            recipes = [
                SELECT
                    Id,
                    Name,
                    Draft__c,
                    Active_Time__c,
                    Active_Time_Units__c,
                    Complexity__c,
                    Needs_Review__c,
                    Possible_Duplicate__c,
                    Season__c
                FROM Recipe__c
                WHERE Name LIKE :searchTerm
                ORDER BY Name
                LIMIT 50
            ];
        }

        System.debug('returning: ' + recipes);
        return recipes;
    }
     @AuraEnabled
    public static void addIngredient(String ingredientName, Decimal measurementAmount, String measurementType, ID recipeId){

        //checking ingredient parameters
        if(ingredientName.trim() == null || measurementType.trim() == '' || measurementAmount == null){
            throw new AuraHandledException('Ingredient name cannot be empty.');
        }
        else 
        {
            // Insert the ingredient
            Ingredient__c newIngredient = new Ingredient__c(
            Name = ingredientName,
            Measurement__c = measurementAmount,
            Measurement_Type__c = measurementType,
            Recipe__c = recipeId);

            insert newIngredient;
        }
        
    }

    @AuraEnabled
    public static List <Ingredient__c> generateGroceryList(ID recipeId){
        // Load the ingredients and return them
        List<Ingredient__c> ingredients = [SELECT Id, Name, Measurement__c, Measurement_Type__c, Recipe__c FROM Ingredient__c WHERE Recipe__c = :recipeId];
        if(ingredients.size() > 0){
            return ingredients;
        }
        return ingredients;
    }

    @AuraEnabled
    public static List <Ingredient__c> scaleRecipeForServings (ID recipeId, Decimal desiredServings) {
        // Scale the recipe and return the list of scaled ingredients
        List<Ingredient__c> ingredients = [SELECT Id, Name, Measurement__c, Measurement_Type__c, Recipe__c FROM Ingredient__c WHERE Recipe__c = :recipeId];
       
        Integer intserv = desiredServings.setScale(0, System.RoundingMode.HALF_UP).intValue();

        for (Ingredient__c i : ingredients) {
            i.Measurement__c = intserv;    
        }   
        return ingredients;
    }

}