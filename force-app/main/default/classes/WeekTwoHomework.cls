public with sharing class WeekTwoHomework {
    public WeekTwoHomework() {

    }

    //A method that includes a query for a List of contacts and includes the Account Name and Industry as well. 
    //Use a loop to print the name of each Contact’s Account Name with System.debug.
    public static void ContactWithAccountName()
    {
        List<Contact> lstContactWithAcctName = [SELECT ID, Name, Account.Name, Account.Industry FROM Contact];
        for(Contact c : lstContactWithAcctName)
        {
            System.debug('Contact Name: ' + c.Name + ' Account Name: ' + c.Account.Name + ' Account Industry: ' + c.Account.Industry);
        }
    }

    //A method that includes a query for a list of Accounts AND includes all their closed-won opportunities in a subquery. 
    //Use a loop to print out the name of each Account’s opportunity with System.debug.
    public static void AccountWithOpportunities()
    {
        List<Account> lstAccountsWithOpportunies =[Select Id,Name, (Select Id, Name from Opportunities where StageName = 'Closed Won') from Account];

        for(Account aa:lstAccountsWithOpportunies)
        {
            for(Opportunity oo:aa.Opportunities)
            {
                System.debug('Account Name: ' + aa.Name + ' Opportunity Name: ' + oo.Name);
            }
        }

    }
    //A method that queries for Opportunity records that returns results in a map format.
    public static void OpportunityMap()
    {

        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>([Select Id, Name, Amount from Opportunity]);
        System.debug(mapOpportunity);
    }
    //An aggregate results query that returns an integer equal to the total number of open opportunities in your org.
    public static void TotalOpportunities()
    {
        Integer intOppCount = [Select count() from Opportunity];
        system.Debug('Number\'s of opprtunies in Org are' + intOppCount + '');
    }

}