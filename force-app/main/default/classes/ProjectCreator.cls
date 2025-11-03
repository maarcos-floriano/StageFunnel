// ProjectCreator.cls
public with sharing class ProjectCreator {
    public static void createProjectFromOpportunity(Opportunity o) {
        try {
            Project__c p = new Project__c();
            p.Name = 'Project - ' + o.Name;
            p.Opportunity__c = o.Id;
            p.Tecnologia__c = o.Tecnologia_do_Projeto__c;
            p.Tempo_Estimado__c = o.Tempo_Estimado__c;
            p.Data_Inicio__c = o.Data_Inicio__c;
            p.Data_Fim__c = o.Data_Fim__c;
            p.Custo_Estimado__c = o.Custo_Estimado__c;
            p.Valor_Proposta__c = o.Valor_Proposta__c;
            insert p;

            List<Developer_Allocation__c> allocations = [SELECT Id, Developer__c FROM Developer_Allocation__c WHERE Opportunity__c = :o.Id];
            for (Developer_Allocation__c a : allocations) {
                a.Project__c = p.Id;
            }
            if (!allocations.isEmpty()) update allocations;

        } catch (Exception e) {
            System.debug('Erro ao criar Project: ' + e.getMessage());
        }
    }

    public static Messaging.SingleEmailMessage buildFormalizationEmail(Opportunity o) {
        List<OpportunityContactRole> ocrs = [SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :o.Id LIMIT 1];
        if (ocrs.isEmpty()) return null;
        Contact c = [SELECT Id, Email, Name FROM Contact WHERE Id = :ocrs[0].ContactId LIMIT 1];
        if (c.Email == null) return null;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { c.Email });
        mail.setSubject('Documento para assinatura - ' + o.Name);
        mail.setPlainTextBody('Olá ' + c.Name + ',\n\nSegue em anexo o documento para assinatura referente à oportunidade: ' + o.Name + '\n\nAtenciosamente.');

        List<ContentDocumentLink> links = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :o.Id LIMIT 1];
        if (!links.isEmpty()) {
            ContentVersion cv = [SELECT VersionData, Title, PathOnClient FROM ContentVersion WHERE ContentDocumentId = :links[0].ContentDocumentId ORDER BY VersionNumber DESC LIMIT 1];
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(cv.Title);
            efa.setBody(cv.VersionData);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });
        }
        return mail;
    }
}