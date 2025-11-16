/*Create a Trigger that processes after insert and after update on Lead
*/
trigger LeadTrigger on Lead(after insert, after update) {

    //initialize the handler class with passing trigger parameter
    LeadTriggerHandler leadhandler = new LeadTriggerHandler(trigger.New,trigger.Old, Trigger.newMap, Trigger.oldMap);
    
    //Check for after insert and after update
    if(trigger.isAfter)     
    {
        if(trigger.isInsert)//if after insert is fired
            leadhandler.handleAfterInsert();
        else if(trigger.isUpdate)//if after update is fired
            leadhandler.handleAfterUpdate();
    }   

}