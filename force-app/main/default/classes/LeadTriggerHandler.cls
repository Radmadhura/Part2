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
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        CreateTaskforLead();//create task after lead is created 
        hasRunOnce = false;//mark it false after runing the logic

    }

     public void handleAfterUpdate(){
        if(hasRunOnce){
            return;
        }
        hasRunOnce = true;//mark it true to run the logic
        CreateTaskforLead();//create task after lead is updated 
        hasRunOnce = false;//mark it false after runing the logic

    }

    public void CreateTaskforLead()
    {
        List<Task> lstTask = new List<Task>();
        Set<Id> leadIdsWithStatusChange = new Set<Id>();
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
                if(nl.Status != OldLeadmaps.get(nl.Id).Status)
                {
                    //add leadid to the list whose status has been changed
                    leadIdsWithStatusChange.add(nl.Id);

                    //Update Task for updated status of lead
                    Task t = new Task();
                    t = AddTask(nl,OldLeadmaps.get(nl.Id).Status,userid);
                    lstTask.add(t);                    
                }
            }
             
            // 1. Query for existing tasks related to the leads
            List<Task> oldtasksToUpdate = [SELECT Id FROM Task WHERE WhoId IN :leadIdsWithStatusChange];
            for(task t: oldtasksToUpdate)
            {
                t.Status = 'Completed';
                lstTask.add(t);
            }

            Upsert  lstTask;//Update or Insert the task the task
        }

    }

    //Create a task object and return
    Public Task AddTask(lead objLead, string oldstatus,Id userid)
    {
        Task t = new Task();
        t.WhatId = objLead.Id;
        t.Subject = 'Follow up on Lead ' + objLead.name;
        t.Status = 'Not Started';
        if(String.isBlank(oldstatus))
            t.Description = 'Lead interest is in ' + objLead.Status;            
        else
            t.Description = 'Lead interest has been changed from ' + oldstatus + ' to ' + objLead.Status;
        t.Priority = 'Normal';
        t.Ownerid = userid;
        
        return t;
    }

  
}