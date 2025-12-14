// Test Factory example from Trailhead: https://trailhead.salesforce.com/en/content/learn/modules/unit-testing-on-the-lightning-platform/generate-data-for-tests

@IsTest
public class TestFactory {
    public static Account getAccount(String name, Boolean doInsert) {
        Account a = new Account(name = name);
        if (doInsert) {
            insert a;
        }
        return a;
    }

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

    public static void generateAccountWithContacts(Integer numContacts) {
        Account a = getAccount('default account ltd', true);
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numContacts; i++) {
            String contactName = 'contact' + i;
            contacts.add(getContact(a.id, contactName, contactName, false));
        }
        insert contacts;
    }

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
}

   