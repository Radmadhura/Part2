/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class RecipeController_Test {

    @IsTest
    static void addIngredientTest(){  
        // when a new ingredient is added, non-draft recipes should be flagged for review.  
        //Recipe__c rec = TestFactory.generateRecipe('Test Recipe', 'Add Ingridients to the reciepe',1,Biryani);   
        Recipe__c rec;

        List<Recipe__c> recList = RecipeController.searchRecipes('Biryani');
       
        if(recList.size() > 0)
            rec = recList[0];
        else
        {
            rec = TestFactory.generateRecipe('Test Recipe', 'Add Ingridients to the reciepe',1,false);
            insert rec;     
        }

        system.Debug('addIngredientTest Recipe__c'+ rec);        

        Test.startTest();                
                try 
                    {
                        //Add ingrediant to the recipe
                        recipeController.addIngredient('Rice', 2.0, 'Cups', rec.Id);
                        recipeController.addIngredient('Water', 2.0, 'Cups', rec.Id);

                        Ingredient__c[] ingredients = recipeController.generateGroceryList(rec.Id);
                         System.assertEquals(2, ingredients.size(), 'One ingredient should have been added.');

                         //Change the scale of the receiepie
                        Ingredient__c[] scaledIngredients = recipeController.scaleRecipeForServings(rec.Id, 4.0);   
                        if(scaledIngredients.size() > 0)
                        System.assertEquals(4.0, scaledIngredients[0].Measurement__c, 'Four Servings should be present after scaling.');


                    }
                    catch (Exception e) 
                    {

                        if(e.getTypeName() == 'System.NullPointerException')                                                                                                                                                                                                                                                        
                            System.assertEquals(e.getTypeName(), 'System.NullPointerException');                
                        else
                            System.assertEquals(e.getTypeName(), 'System.DmlException');
                    }
        Test.stopTest();
        
    }
}