// CNPJService.cls
public with sharing class CNPJService {
    
    public class CNPJInfo {
        public String cnpj;
        public String razaoSocial;
        public String nomeFantasia;
    }

    public class CNPJException extends Exception {}
    
    public static CNPJInfo fetchCNPJ(String cnpj) {
        if (String.isBlank(cnpj)) {
            throw new CNPJException('CNPJ vazio');
        }
        String cleaned = cnpj.replaceAll('[^0-9]','');
        String endpoint = 'https://brasilapi.com.br/api/cnpj/v1/' + cleaned;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('User-Agent', 'StageFunnel-SFDC/1.0');
        req.setHeader('Accept', 'application/json');
        req.setMethod('GET');

        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CNPJException('CNPJ não encontrado ou inativo na Receita Federal. Código: ' + res.getStatusCode() + '. Corpo da Resposta: ' + res.getBody());
        }

        Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        CNPJInfo info = new CNPJInfo();
        info.cnpj = cleaned;


        if (payload.containsKey('razao_social')) {
            info.razaoSocial = (String) payload.get('razao_social');
        } else if (payload.containsKey('nome')) { 
            info.razaoSocial = (String) payload.get('nome');
        }

        if (payload.containsKey('nome_fantasia')) {
            info.nomeFantasia = (String) payload.get('nome_fantasia');
        } else if (payload.containsKey('fantasia')) {
            info.nomeFantasia = (String) payload.get('fantasia');
        }

        if (String.isBlank(info.nomeFantasia)) {
            info.nomeFantasia = info.razaoSocial;
        }

        return info;
    }
    public class EntradaCNPJ {
        @InvocableVariable(required=true)
        public String cnpj;
    }

    public class SaidaCNPJ {
        @InvocableVariable
        public String razaoSocial;

        @InvocableVariable
        public String nomeFantasia;
    }

    @InvocableMethod(label='Buscar CNPJ BrasilAPI')
    public static List<SaidaCNPJ> buscarCNPJ(List<EntradaCNPJ> entradas) {
        
        List<SaidaCNPJ> resultados = new List<SaidaCNPJ>();
        
        for (EntradaCNPJ entrada : entradas) {
            SaidaCNPJ resultado = new SaidaCNPJ();
            
            try {
                String cleanedCNPJ = entrada.cnpj.replaceAll('[^0-9]','');
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://brasilapi.com.br/api/cnpj/v1/' + cleanedCNPJ);
                req.setHeader('User-Agent', 'StageFunnel-SFDC/1.0');
                req.setHeader('Accept', 'application/json');
                req.setMethod('GET');
                
                HttpResponse res = http.send(req);

                System.debug('Código de resposta: ' + res.getStatusCode());
                
                if(res.getStatusCode() == 200) {
                    Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    resultado.razaoSocial = (String) jsonMap.get('razao_social');
                    resultado.nomeFantasia = (String) jsonMap.get('nome_fantasia');
                } else {
                    resultado.razaoSocial = 'Não encontrado';
                    resultado.nomeFantasia = 'Não encontrado';
                }
                
            } catch(Exception e) {
                resultado.razaoSocial = 'Erro: ' + e.getMessage();
                resultado.nomeFantasia = 'Erro: ' + e.getMessage();
            }
            
            resultados.add(resultado);
        }
        
        return resultados;
    }
}