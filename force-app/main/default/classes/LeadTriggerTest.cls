@isTest
private class LeadTriggerTest {
    @isTest static void testLeadCreationCallsBrasilAPIAndCreatesTask() {
        Test.setMock(HttpCalloutMock.class, new HttpCNPJMock());
        Lead l = new Lead(FirstName='Teste', LastName='Lead', Company='Temp', CNPJ__c='44.605.692/0001-77');
        Test.startTest();
            insert l;
        Test.stopTest();

        Lead ldb = [SELECT Id, Razao_Social__c, Nome_Fantasia__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals('STAGE CONSULTING SERVIÇOS E CONSULTORIA EMPRESARIAL LTDA', ldb.Razao_Social__c);
        Integer tcount = [SELECT count() FROM Task WHERE WhatId = :l.Id];
        System.assert(tcount > 0);
    }
}