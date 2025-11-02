public class CNPJQueueable implements Queueable, Database.AllowsCallouts {

    private List<Lead> leadsToProcess;

    public CNPJQueueable(List<Lead> leads) {
        this.leadsToProcess = leads;
    }

    public void execute(QueueableContext context) {
        
        List<Lead> leadsForUpdate = new List<Lead>();
        
        for (Lead ld : this.leadsToProcess) {
            
            try {
                CNPJService.CNPJInfo info = CNPJService.fetchCNPJ(ld.CNPJ__c); 
                
                Lead updatedLead = new Lead(
                    Id = ld.Id,
                    Razao_Social__c = info.razaoSocial,
                    Nome_Fantasia__c = info.nomeFantasia
                );
                
                leadsForUpdate.add(updatedLead);
                
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'ERRO_QUEUEABLE: Falha no CNPJService para Lead ' + ld.Id + ': ' + e.getMessage()); 
            }
        }
        
        if (!leadsForUpdate.isEmpty()) {
            try {
                update leadsForUpdate;
            } catch (DMLException dmlEx) {
                 System.debug(LoggingLevel.ERROR, 'ERRO_QUEUEABLE_DML: Falha na atualização dos Leads: ' + dmlEx.getMessage()); 
            }
        }
    }
}