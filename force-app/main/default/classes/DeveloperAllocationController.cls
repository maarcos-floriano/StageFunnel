// DeveloperAllocationController.cls
public with sharing class DeveloperAllocationController {
    @AuraEnabled(cacheable=true)
    public static List<Developer__c> fetchDevelopers(String tecnologia) {
        String likeVal = '%' + tecnologia + '%';
        return [
            SELECT Id, Name, Especialidade__c, Email__c
            FROM Developer__c
            WHERE Especialidade__c LIKE :likeVal
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static void allocateDevelopers(Id opportunityId, List<Id> developerIds, Date startDate, Date endDate) {
        List<Developer_Allocation__c> allocations = new List<Developer_Allocation__c>();
        for (Id devId : developerIds) {
            Developer_Allocation__c a = new Developer_Allocation__c();
            a.Opportunity__c = opportunityId;
            a.Developer__c = devId;
            a.Data_Inicio__c = startDate;
            a.Data_Fim__c = endDate;
            allocations.add(a);
        }
        if (!allocations.isEmpty()) {
            try {
                insert allocations;
            } catch (Exception e) {
                System.debug('Erro ao criar Developer Allocation: ' + e.getMessage());
            }
        }
    }
}