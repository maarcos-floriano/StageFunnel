@isTest
private class OpportunityTriggerTest {
    @isTest static void testOpportunityFormalizationEmailAndProjectCreation() {
        Account a = new Account(Name='ACME');
        insert a;
        Opportunity o = new Opportunity(Name='Opp Test', StageName='Qualificação', CloseDate=Date.today(), AccountId=a.Id);
        insert o;

        Contact c = new Contact(FirstName='Joao', LastName='Cliente', Email='cliente@example.com', AccountId=a.Id);
        insert c;
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=o.Id, ContactId=c.Id, Role='Decision Maker', IsPrimary=true);
        insert ocr;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'proposta.pdf';
        cv.PathOnClient = 'proposta.pdf';
        cv.VersionData = Blob.valueOf('pdfcontent');
        insert cv;
        ContentDocumentLink lnk = new ContentDocumentLink(ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId, LinkedEntityId = o.Id, ShareType = 'V');
        insert lnk;

        o.StageName = 'Formalização';
        o.Documentos_Assinados__c = 'proposta.pdf';
        Test.startTest();
            update o;
        Test.stopTest();

        o.StageName = 'Fechado ganho';
        System.assertEquals(true, o.IsWon);
        Test.startTest();
            update o;
        Test.stopTest();

        Integer pc = [SELECT count() FROM Project__c WHERE Opportunity__c = :o.Id];
        System.assert(pc == 1);
    }
}
