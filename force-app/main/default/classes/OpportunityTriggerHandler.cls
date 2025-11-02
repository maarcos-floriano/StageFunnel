// OpportunityTriggerHandler.cls
public with sharing class OpportunityTriggerHandler {
    public static void beforeUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        for (Opportunity o : newOpps) {
            Opportunity oldOpp = oldMap.get(o.Id);
            if (oldOpp != null && oldOpp.StageName != o.StageName) {
                if (o.StageName == 'Negociação' || o.StageName == 'Negociacao') {
                    if (o.Valor_Proposta__c == null) {
                        o.addError('Não é possível mover para Negociação sem Valor da Proposta preenchido.');
                    }
                }
                if (o.StageName == 'Formalização' || o.StageName == 'Formalizacao') {
                    if (o.Documentos_Assinados__c == null) {
                        o.addError('Anexe documentos assinados antes de mover para Formalização.');
                    }
                }
            }
        }
    }

    public static void afterUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity o : newOpps) {
            Opportunity oldOpp = oldMap.get(o.Id);
            if (oldOpp != null && oldOpp.StageName != o.StageName && (o.StageName == 'Formalização' || o.StageName == 'Formalizacao')) {
                Messaging.SingleEmailMessage mail = ProjectCreator.buildFormalizationEmail(o);
                if (mail != null) emails.add(mail);
            }
            if (oldOpp != null && oldOpp.StageName != o.StageName && o.IsWon) {
                ProjectCreator.createProjectFromOpportunity(o);
            }
        }
        if (!emails.isEmpty()) Messaging.sendEmail(emails);
    }

    public static void afterInsert(List<Opportunity> newOpps) {
        // placeholder
    }
}
