public with sharing class WeeKThreeHomework {
    public WeeKThreeHomework() {

    }

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

/*Create a Handler class for your trigger that contains all the trigger logic
*/
public with sharing class LeadTriggerHandler {
   
    static Boolean hasRunOnce = false; //Has the Account trigger already executed? 
    List<Lead> NewLeads; //new lead list
    List<Lead> OldLeads; //Old lead list
    Map<Id,Lead> NewLeadmaps;//New lead map with id and lead object
    Map<Id,Lead> OldLeadmaps;//old lead map with id and lead object

     public LeadTriggerHandler(List<Lead> NewLeads, List<Lead> OldLeads, Map<Id,Lead> NewLeadmaps, Map<Id,Lead> OldLeadmaps) {
        //intiating the values in constructor
        this.NewLeads = NewLeads;
        this.OldLeads = OldLeads;
        this.NewLeadmaps = NewLeadmaps;
        this.OldLeadmaps = OldLeadmaps;
    }


    public void handleAfterInsert(){
        System.debug('In handleAfterInsert' + hasRunOnce);
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        CreateTaskforLead();//create task after lead is created 
        hasRunOnce = false;//mark it false after runing the logic

    }

     public void handleAfterUpdate(){
         System.debug('In handleAfterUpdate' + hasRunOnce);
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        CreateTaskforLead();//create task after lead is updated 
        hasRunOnce = false;//mark it false after runing the logic

    }

    public void CreateTaskforLead()
    {
        
         System.debug('In CreateTaskforLead' + hasRunOnce);
        List<Task> lstTask = new List<Task>();
        Set<Id> leadIdsWithPrdIntChange = new Set<Id>();
        id userid = UserInfo.GetUserId();

        if(Trigger.isInsert)//if triggered is fired on inserting the record
        {        
            for(Lead l: NewLeads)
            {
                //Create a new Task for each lead              
                Task t = new Task();
                t = AddTask(l,'',userid);
                lstTask.add(t);//add task to templist
            } 
            
            Insert lstTask;//insert the task
        }

        if(trigger.isUpdate)//if triggered is fired on updating the record
        {
            for(lead nl: NewLeads)
            {  
                if(nl.ProductInterest__c != OldLeadmaps.get(nl.Id).ProductInterest__c)
                {
                    //add leadid to the list whose status has been changed
                    leadIdsWithPrdIntChange.add(nl.Id);

                    //Update Task for updated status of lead
                    Task t = new Task();
                    t = AddTask(nl,OldLeadmaps.get(nl.Id).ProductInterest__c,userid);
                    lstTask.add(t);                    
                }
            }
             
            // 1. Query for existing tasks related to the leads
            List<Task> oldtasksToUpdate = [SELECT Id FROM Task WHERE WhoId IN :leadIdsWithPrdIntChange];
            for(task t: oldtasksToUpdate)
            {
                t.Status = 'Completed';
                lstTask.add(t);
            }

            Upsert  lstTask;//Update or Insert the task the task
        }

    }

    //Create a task object and return
    Public Task AddTask(lead objLead, string oldprdstatus,Id userid)
    {
        Task t = new Task();
        t.WhoId = objLead.Id;
        t.Subject = 'Follow up on Lead ' + objLead.FirstName + ' ' + objLead.LastName ;
        t.Status = 'Not Started';
        if(String.isBlank(oldprdstatus))
            t.Description = 'Lead interest is in ' + objLead.ProductInterest__c;            
        else
            t.Description = 'Lead interest has been changed from ' + oldprdstatus + ' to ' + objLead.ProductInterest__c;
        t.Priority = 'Normal';
        t.Ownerid = userid;
        
        return t;
    }

  
}
}