// LeadTriggerHandler.cls
public with sharing class LeadTriggerHandler {
    
    public static void beforeInsert(List<Lead> newLeads) {
        for (Lead ld : newLeads) {
             if (!String.isBlank(ld.CNPJ__c)) {
                ld.CNPJ__c = ld.CNPJ__c.replaceAll('[^0-9]','');
             }
        }
    }

    public static void afterInsert(List<Lead> newLeads) {
    
        List<Lead> leadsForQueueable = new List<Lead>();
        List<Task> tasks = new List<Task>();
        
        for (Lead ld : newLeads) {
            if (!String.isBlank(ld.CNPJ__c)) {
                leadsForQueueable.add(ld); 
            }
            
            Task t = new Task(
                Subject = 'Contato inicial - Lead',
                WhoId = ld.Id,
                Priority = 'Normal',
                Status = 'Not Started',
                OwnerId = ld.OwnerId,
                ActivityDate = Date.today(),
                IsReminderSet = true,
                Description = 'Entrar em contato com o lead criado. CNPJ: ' + ld.CNPJ__c
            );
            tasks.add(t);
        }
        
        if (!leadsForQueueable.isEmpty()) {
            System.debug('*** DEBUG HANDLER (SÍNCRONO): Enfileirando CNPJQueueable para ' + leadsForQueueable.size() + ' Leads.');
            
            CNPJQueueable job = new CNPJQueueable(leadsForQueueable);
            System.enqueueJob(job); 
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }
}