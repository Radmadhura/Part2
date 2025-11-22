trigger RecipeTrigger on Recipe__c (before insert, Before update, after insert, after update) {

    //initialize the handler class with passing trigger parameter
    RecipeTriggerHandler recipehandler = new RecipeTriggerHandler(trigger.New,trigger.Old, Trigger.newMap, Trigger.oldMap);
    
    //Check for after insert and after update
    if(trigger.isBefore)     
    {
        if(trigger.isInsert)//if after insert is fired
            recipehandler.handleBeforeInsert();
        else if(trigger.isUpdate)//if after update is fired
            recipehandler.handleBeforeUpdate();
    }   
    if(trigger.isAfter)         
    {   
        if(trigger.isUpdate)//if after update is fired
            recipehandler.handleAfterUpdate();
    }
}