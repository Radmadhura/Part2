/*Create a Trigger that processes after insert and after update on Lead
*/

trigger LeadTrigger on Lead(after insert, after update) {

    //initialize the handler class with passing trigger parameter
    LeadTriggerHandler leadhandler = new LeadTriggerHandler(trigger.New,trigger.Old, Trigger.newMap, Trigger.oldMap)

}