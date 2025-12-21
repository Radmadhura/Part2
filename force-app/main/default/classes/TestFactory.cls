// Test Factory example from Trailhead: https://trailhead.salesforce.com/en/content/learn/modules/unit-testing-on-the-lightning-platform/generate-data-for-tests

@IsTest
public class TestFactory {
    // Methods to generate test data
    public static Account getAccount(String name, Boolean doInsert) {
        Account a = new Account(name = name);
        if (doInsert) {
            insert a;
        }
        return a;
    }

    // Overloaded method to generate Contact with Account Id
    public static Contact getContact(
        Id accountId,
        String fname,
        String lname,
        Boolean doInsert
    ) {
        Contact c = new Contact(
            firstName = fname,
            lastName = lname,
            accountId = accountId
        );
        if (doInsert) {
            insert c;
        }
        return c;
    }

    // Method to generate Account with multiple Contacts
    public static void generateAccountWithContacts(Integer numContacts) {
        Account a = getAccount('default account ltd', true);
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numContacts; i++) {
            String contactName = 'contact' + i;
            contacts.add(getContact(a.id, contactName, contactName, false));
        }
        insert contacts;
    }
    // Method to generate multiple Opportunities for an Account
    public static List<Opportunity> generateOppsForAccount(
        id accountId,
        Decimal amount,
        Integer numOpps
    ) {
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < numOpps; i++) {
            Opportunity o = new Opportunity();
            o.name = 'Account ' + i;
            o.accountId = accountid;
            o.amount = amount;
            o.closeDate = Date.today().addDays(5);
            o.stageName = 'Prospecting';
            opps.add(o);
        }
        return opps;
    }

    // Method to generate User with specified Profile
    public static User generateUser(String profileName) {
        UserRole userRole = new UserRole(
            DeveloperName = 'TestingTeam',
            Name = 'Testing Team'
        );
        insert userRole;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName]
            .Id,
            LastName = 'last',
            Email = 'Cpt.Awesome@awesomesauce.com',
            Username = 'Cpt.Awesome@awesomesauce.com',
            CompanyName = 'Testing Co',
            Title = 'Captian',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = userRole.Id
        );
        insert u;
        return u;
    }

    // Method to generate Recipe
    public static Recipe__c generateRecipe(String name, String description, integer iComplexity, Boolean doInsert ) 
    {
        Recipe__c r = new Recipe__c(
            Name = name,
            Description__c = description
        );
        //compare interger iComplexity to set recipe fields for complexity

        if(iComplexity == 0)//Simple
        {
            r.Active_Time__c = 5;
            r.Active_Time_Units__c = 'Minutes';
            r.Servings__c = 3;
        }
        else if(iComplexity == 1)//Moderate
        {
            r.Active_Time__c = 30;
            r.Active_Time_Units__c = 'Minutes';
            r.Servings__c = 7;  
        }
        else if(iComplexity == 2)//Difficult
        {
            r.Active_Time__c = 2;
            r.Active_Time_Units__c = 'Hours';
            r.Servings__c = 15;  
        }

        if (doInsert) {
            insert r;
        }
        return r;
    }

    // Method to generate Cookbook
    public static cookbook__c generateCookbook(
        String name,
        String status,
        Boolean doInsert
    ) {
        cookbook__c cb = new cookbook__c(
            Name = name,
            Status__c = status
        );
        if (doInsert) {
            insert cb;
        }
        return cb;
    }

    // Method to generate Recipe with Cookbook in Draft status
    public static void getrecipeWithCookbookWithDraft(String recipeName, String cookbookName,integer Complexity) 
    {
        Recipe__c rec = generateRecipe(recipeName, recipeName + ' Draft Desciption', Complexity, true);
        cookbook__c cb = generateCookbook(cookbookName, 'Draft', true);

        Recipe_Usage__c ru = new Recipe_Usage__c(
            Recipe__c = rec.Id,
            Cookbook__c = cb.Id
        );
        insert ru;  
    }

    // Method to generate Recipe with Cookbook in Published status
     public static void getrecipeWithCookbookWithPublished(String recipeName, String cookbookName,integer Complexity) 
        {
        Recipe__c rec = generateRecipe(recipeName, recipeName + ' Published Desciption',Complexity, true);
        cookbook__c cb = generateCookbook(cookbookName, 'Published',true);

        Recipe_Usage__c ru = new Recipe_Usage__c(
            Recipe__c = rec.Id,
            Cookbook__c = cb.Id
        );
        insert ru;  
    }



    //test Methods for RecipeController_test

    /* 
        Method 1: Creates and returns a list of Ingredient SObject records with dummy data.
    It should take a parameter that dictates the number of Ingredient objects to be returned
    Each Ingredient in the list should have a different name (hint, this can be Ingredient1, Ingredient2 etc)
    It should create the objects in-memory and return them, WITHOUT INSERTING
    */
    public static List<Ingredient__c> generateIngredients(Integer numIngredients) 
    {
        List<Ingredient__c> lstingredients = new List<Ingredient__c>();

        for (Integer i = 0; i < numIngredients; i++) {

            Ingredient__c ingdnt = new Ingredient__c();
            
            ingdnt.Name = 'Ingredient ' + i;
            ingdnt.Measurement__c = 1.0;
            ingdnt.Measurement_Type__c = 'Cups';

            lstingredients.add(ingdnt);
        }

        return lstingredients;
    }

    /*  Method 2: Creates, inserts, and returns Ingredient SObjects
        It should take a parameter of a Recipe Id to associate the Ingredient to
        It should take a parameter that dictates the number of Ingredients to be created and returned
        Each Ingredient in the list should have a different name
        It SHOULD INSERT the records and return them 
    */
    public static List<Ingredient__c> generateIngredientsForRecipe(Id recipeId,Integer numIngredients) 
    {
        List<Ingredient__c> lstingredients = new List<Ingredient__c>();

          for (Integer i = 0; i < numIngredients; i++) {
            
            Ingredient__c ingdnt = new Ingredient__c();
            
            ingdnt.Name = 'Ingredient ' + i;
            ingdnt.Measurement__c = 1.0;
            ingdnt.Measurement_Type__c = 'Cups';
            ingdnt.Recipe__c = recipeId;

            lstingredients.add(ingdnt);
        }

        //Insert all ingredient for receipieid       
        insert lstingredients;

        //return list of lstingredients
        return lstingredients;
    }   

    /*  Method 3: Creates, inserts and returns a list of Recipe SObject records with dummy data.
        It should take the following parameters: 
        A number that dictates the number of Recipe objects to be created and returned 
        A number that dictates the number of ingredients to be added as children of each recipe.
        Bonus: can you reduce the amount of repetitive code by reusing one of the other methods in this test data factory?
     */
    public static List<Recipe__c> generateRecipesWithIngredients(Integer numRecipes, Integer numIngredientsPerRecipe) 
    {
        List<Recipe__c> lstrecipes = new List<Recipe__c>();

        for (Integer i = 0; i < numRecipes; i++) {

            Recipe__c rec = new Recipe__c();
            rec.Name = 'Recipe ' + i;
            rec.Description__c = 'Description for Recipe ' + i;
            rec.Active_Time__c = 10;
            rec.Active_Time_Units__c = 'Minutes';
            rec.Servings__c = 4;

            lstrecipes.add(rec);
        }

        //Insert all recipes       
        insert lstrecipes;

        //For each recipe, generate ingredients
        for(Recipe__c r : lstrecipes)
        {
            generateIngredientsForRecipe(r.Id, numIngredientsPerRecipe);
        }

        //return list of receipies
        return lstrecipes;
    }

}