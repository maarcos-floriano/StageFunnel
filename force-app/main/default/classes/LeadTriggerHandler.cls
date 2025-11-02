// LeadTriggerHandler.cls
public with sharing class LeadTriggerHandler {
    public static void beforeInsert(List<Lead> newLeads) {
        for (Lead ld : newLeads) {
            if (!String.isBlank(ld.CNPJ__c)) {
                try {
                    CNPJService.CNPJInfo info = CNPJService.fetchCNPJ(ld.CNPJ__c);
                    ld.Razao_Social__c = info.razaoSocial;
                    ld.Nome_Fantasia__c = info.nomeFantasia;
                } catch (CNPJService.CNPJException e) {
                    ld.addError('Erro ao validar CNPJ: ' + e.getMessage());
                } catch (Exception e) {
                    ld.addError('Erro ao consultar BrasilAPI: ' + e.getMessage());
                }
            }
        }
    }

    public static void afterInsert(List<Lead> newLeads) {
        List<Task> tasks = new List<Task>();
        for (Lead ld : newLeads) {
            Task t = new Task(
                Subject = 'Contato inicial - Lead',
                WhatId = ld.Id,
                OwnerId = UserInfo.getUserId(),
                Status = 'Not Started',
                Priority = 'Normal',
                Description = 'Entrar em contato com o lead criado. CNPJ: ' + ld.CNPJ__c
            );
            tasks.add(t);
        }
        if (!tasks.isEmpty()) insert tasks;
    }
}
