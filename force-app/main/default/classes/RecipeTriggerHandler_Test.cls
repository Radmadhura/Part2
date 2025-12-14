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
private class RecipeTriggerHandler_Test {

    @TestSetup
    static void loadTestData() {    
        // Create a test recipe
        Recipe__c testRecipe = new Recipe__c();
        testRecipe.Name = 'Test Recipe';
        testRecipe.Active_Time__c = 30;
        testRecipe.Active_Time_Units__c = 'Minutes';
    }

    @IsTest
    static void testSimpleRecipe(){  
        // when a new ingredient is added, non-draft recipes should be flagged for review.

        Recipe__c rec = TestFactory.generateRecipe('Simple Recipe', 'It is a simple recipe', 0 , false);   

        Test.startTest();
            insert rec;
        Test.stopTest();

        Recipe__c Insertrec = [SELECT Complexity__c FROM Recipe__c WHERE Id = :rec.Id];
        System.Assert.areEqual('Simple', Insertrec.Complexity__c, 'Recipe should be marked as Simple');
        
    }

    @IsTest
    static void testModerateRecipe(){  
        // when a new ingredient is added, non-draft recipes should be flagged for review.  
        Recipe__c rec = TestFactory.generateRecipe('Moderate Recipe', 'It is a moderate recipe',1,false);   

        Test.startTest();
            insert rec;
        Test.stopTest();    

        Recipe__c Insertrec = [SELECT Complexity__c FROM Recipe__c WHERE Id = :rec.Id];
        System.Assert.areEqual('Moderate', Insertrec.Complexity__c, 'Recipe should be marked as Moderate'); 
    }

    @Istest
    static void testDifficultRecipe(){  
        // when a new ingredient is added, non-draft recipes should be flagged for review.  
        Recipe__c rec = TestFactory.generateRecipe('Difficult Recipe', 'It is a difficult recipe',2,false);   
       
        Test.startTest();
            insert rec;
        Test.stopTest();    

        Recipe__c Insertrec = [SELECT Complexity__c FROM Recipe__c WHERE Id = :rec.Id];
        System.Assert.areEqual('Difficult', Insertrec.Complexity__c, 'Recipe should be marked as Difficult'); 
    }  
    
    
    //test simple update recepie
    @IsTest
    static void testSimpleUpdateRecipe(){  
        // insert simple recipe and then update it
       TestFactory.getRecipeWithCookbookWithDraft('Simple Recipe', 'Cookbook Simple Recipe',0);   

       Recipe__c rec = [SELECT Id, Name, Description__c, Active_Time__c, Servings__c, Draft__c, Complexity__c FROM Recipe__c WHERE Name = 'Simple Recipe' LIMIT 1];
       rec.Description__c = 'Updated Description for Simple Recipe';
     
        Test.startTest();
            update rec;
        Test.stopTest();

        Recipe__c Updaterec = [SELECT Complexity__c FROM Recipe__c WHERE Id = :rec.Id];
        System.Assert.areEqual('Simple', Updaterec.Complexity__c, 'Recipe should be marked as Simple');
    }

    //Wirte a negative test method for recipe with missing fields
    @IsTest
    static void testDraftRecipe(){  
        // insert recipe with missing fields to be marked as draft
       Recipe__c rec = TestFactory.generateRecipe('Draft Recipe', 'It is a Draft recipe',5,false); 

       system.debug('rec before insert: ' + rec);

        Test.startTest();
            try 
            {
                insert rec;
                System.assert(false, 'Exception expected');
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