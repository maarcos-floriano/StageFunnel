@isTest
private class DeveloperAllocationControllerTest {
    @isTest static void testAllocateDevelopers() {
        Developer__c d = new Developer__c(Name='Dev One', Especialidade__c='Salesforce', Email__c='dev@example.com');
        insert d;
        Account a = new Account(Name='ACME');
        insert a;
        Opportunity o = new Opportunity(Name='Opp Dev', StageName='Qualificação', CloseDate=Date.today(), AccountId=a.Id);
        insert o;

        Test.startTest();
            DeveloperAllocationController.allocateDevelopers(o.Id, new List<Id>{d.Id}, Date.today(), Date.today().addDays(30));
        Test.stopTest();

        Integer countAlloc = [SELECT count() FROM Developer_Allocation__c WHERE Opportunity__c = :o.Id];
        System.assertEquals(1, countAlloc);
    }
}
