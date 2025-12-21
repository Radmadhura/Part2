public with sharing class RecipeTriggerHandler {

    static Boolean hasRunOnce = false; //Has the Recipe trigger already executed? 
    List<Recipe__c> NewRecipes; //new Recipes list
    List<Recipe__c> OldRecipes; //Old Recipes list
    Map<Id,Recipe__c> NewRecipemaps;//New Recipes map with id and lead object
    Map<Id,Recipe__c> OldRecipesmaps;//old Recipes map with id and lead object
    id userid = null;
    date todaydate = date.today();

    public RecipeTriggerHandler(List<Recipe__c> NewRecipe, List<Recipe__c> OldRecipe, Map<Id,Recipe__c> NewRecipeMap, Map<Id,Recipe__c> OldRecipeMap) {

        this.NewRecipes = NewRecipe;
        this.OldRecipes = OldRecipe;
        this.NewRecipemaps = NewRecipeMap;
        this.OldRecipesmaps = OldRecipeMap;
        this.userid = UserInfo.GetUserId();
    }

    /*Insert logic*/

    
    //Before Insert
     public void handleBeforeInsert(){
        System.debug('In handleBeforeInsert' + hasRunOnce);
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        EvaluateRecipe(this.NewRecipes);//Evaluate recipe
        hasRunOnce = false;
    }

    /*Update logic*/
    
     //Before Update
     public void handleBeforeUpdate(){
        System.debug('In handleBeforeUpdate' + hasRunOnce);
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        EvaluateRecipe(this.NewRecipes);//Evaluate recipe
        hasRunOnce = false;
    }

    //After Update
     public void handleAfterUpdate(){
        System.debug('In handleAfterUpdate' + hasRunOnce);
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        CreateTaskforRecipeAndCookBooks(this.NewRecipemaps);//Create Tasks after Update    
        hasRunOnce = false;
    }

    //Check key values and set Complexity of the recipe
    public void EvaluateRecipe(list<Recipe__c> listRecipe){
       
        System.debug('In EvaluateRecipe' );
        Integer iComplexity = 0;

        //Validate draft flag
        for (Recipe__c recipe : listRecipe)
        {     
            
             System.debug('In recipe' + recipe);
            if(String.isEmpty(recipe.Name) || recipe.Active_Time__c.intValue() == 0 || String.isEmpty(recipe.Description__c) || recipe.Servings__c.intValue() == 0)
            {
                recipe.Draft__c = true;
            }
            else
            {
                recipe.Draft__c = false;

                //Commented code as we do not need to throw an exeception now
                //recipe.addError( 'Please fill all required field!');
            }

             iComplexity = HelperFunctions.rateRecipeComplexity(recipe);

                //Check Complexity of the recipe
                if(iComplexity ==3)
                    recipe.Complexity__c = 'Difficult';
                else if(iComplexity ==2)
                    recipe.Complexity__c = 'Moderate';
                else
                    recipe.Complexity__c = 'Simple';

        
        }        
    
    }
    
    //Create a Task for the Cookbook recipe
    public void CreateTaskforRecipeAndCookBooks(Map<Id,Recipe__c> listRecipeMaps){

        
        System.debug('In side CreateTaskforRecipeAndCookBooks' );
        Set<Id> recipeID = new Set<Id>();
        Set<Id> cookbookID = new Set<Id>();
        Set<Recipe__c> listRecipe = new Set<Recipe__c>();
        List<Cookbook__c> cookbookList = new List<Cookbook__c>();
        list<Task> lstTaskTobeInserted = new List<Task>();

        System.debug('In side listRecipeMaps.values()' + listRecipeMaps.values());
        for (Recipe__c recipe : listRecipeMaps.values())
        {
            if(recipe.Draft__c == false)
            {
               recipeID.add(recipe.Id);
            }
        }       
            
        //check cookbookUsage objects if receipe exists
        Map<Id, Recipe_Usage__c> listrecipeUsage = new Map<Id, Recipe_Usage__c>([SELECT Id, Recipe__c, Cookbook__c FROM Recipe_Usage__c WHERE Recipe__c IN : recipeID]);

         System.debug('In side listRecilistrecipeUsagepeMaps.values()' + listrecipeUsage.values());
        for (Recipe_Usage__c objrecipeUsage : listrecipeUsage.values())
        {
            if(objrecipeUsage.Cookbook__c != null)
            {
                cookbookID.add(objrecipeUsage.Cookbook__c);
            }
        }

        System.debug('In cookbookID' + cookbookID);
        //get the cook books from the list of cookbook id   
        cookbookList = [SELECT Id, Name, Ownerid FROM Cookbook__c WHERE Id IN : cookbookID];

         System.debug('In side cookbookList' + cookbookList);
        //Create a task for Cookbooks
        IF(cookbookList.size() > 0)
        {
            lstTaskTobeInserted = AddTask(cookbookList);
        }

        //Insert all the tasks
        if(lstTaskTobeInserted.size() > 0)
        {
            Insert lstTaskTobeInserted;
        }

    }
    //Add task for all cookbooks
    Public List<Task> AddTask(List<Cookbook__c> lstCookbook)
    {   
        List<Task> TaskforCookBook = new List<Task>();
            
        for(Cookbook__c objCookbook : lstCookbook)  
        {         
            Task newTask = new Task();
            newTask.WhatId = objCookbook.Id;
            newTask.Subject = 'Review Task for Cookbook -' + objCookbook.Name;
            newTask.Status = 'Not Started';
            newTask.Priority = 'Normal';
            newTask.Ownerid = objCookbook.Ownerid;
            newTask.ActivityDate = this.todaydate.addDays(7);
            TaskforCookBook.add(newTask);
        }
        
        return TaskforCookBook;

    }
}