public class CNPJQueueable implements Queueable, Database.AllowsCallouts {

    // 1. Variável de instância para receber os Leads do Trigger
    private List<Lead> leadsToProcess;

    // 2. Construtor para inicializar a lista de Leads
    public CNPJQueueable(List<Lead> leads) {
        // Apenas Leads que têm CNPJ preenchido são passados
        this.leadsToProcess = leads;
    }

    // 3. Método execute (é o que roda assincronamente)
    public void execute(QueueableContext context) {
        
        List<Lead> leadsForUpdate = new List<Lead>();
        
        // Agora, iteramos sobre a lista que recebemos do Trigger
        for (Lead ld : this.leadsToProcess) {
            
            // O CNPJService.fetchCNPJ ainda fará o callout
            try {
                CNPJService.CNPJInfo info = CNPJService.fetchCNPJ(ld.CNPJ__c); 
                
                System.debug('DEBUG_QUEUEABLE: Callout SUCESSO para Lead ' + ld.Id + '. Razão Social: ' + info.razaoSocial); 

                // Prepara o Lead para atualização (apenas Id e campos a serem alterados)
                Lead updatedLead = new Lead(
                    Id = ld.Id,
                    Razao_Social__c = info.razaoSocial,
                    Nome_Fantasia__c = info.nomeFantasia
                );
                
                leadsForUpdate.add(updatedLead);
                
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'ERRO_QUEUEABLE: Falha no CNPJService para Lead ' + ld.Id + ': ' + e.getMessage()); 
                // Você pode adicionar lógica aqui para registrar o erro no próprio Lead
            }
        }
        
        // 4. DML: Atualiza os Leads
        if (!leadsForUpdate.isEmpty()) {
            try {
                update leadsForUpdate;
                System.debug('DEBUG_QUEUEABLE: ' + leadsForUpdate.size() + ' Leads atualizados com sucesso.');
            } catch (DMLException dmlEx) {
                 System.debug(LoggingLevel.ERROR, 'ERRO_QUEUEABLE_DML: Falha na atualização dos Leads: ' + dmlEx.getMessage()); 
            }
        }
    }
}