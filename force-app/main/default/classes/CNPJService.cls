// CNPJService.cls
public with sharing class CNPJService {
    public class CNPJInfo {
        public String cnpj;
        public String razaoSocial;
        public String nomeFantasia;
    }

    // Faz callout para BrasilAPI e retorna informações (lança exception em caso de CNPJ inválido)
    @future(callout=true)
    public static void fetchCNPJAsync(String leadId, String cnpj) {
        // This async method is unused in this package but left for extension.
    }

    public static CNPJInfo fetchCNPJ(String cnpj) {
        if (String.isBlank(cnpj)) {
            throw new CNPJException('CNPJ vazio');
        }
        String cleaned = cnpj.replaceAll('[^0-9]','');
        String endpoint = 'https://brasilapi.com.br/api/cnpj/v1/' + cleaned;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Accept','application/json');
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CNPJException('CNPJ não encontrado ou inativo na Receita Federal. Código: ' + res.getStatusCode());
        }

        Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
        CNPJInfo info = new CNPJInfo();
        info.cnpj = cleaned;

        if (payload.containsKey('razao_social')) info.razaoSocial = (String) payload.get('razao_social');
        if (payload.containsKey('razaoSocial')) info.razaoSocial = (String) payload.get('razaoSocial');
        if (payload.containsKey('nome')) {
            if (info.razaoSocial == null) info.razaoSocial = (String) payload.get('nome');
        }
        if (payload.containsKey('fantasia')) info.nomeFantasia = (String) payload.get('fantasia');
        if (payload.containsKey('nome_fantasia')) info.nomeFantasia = (String) payload.get('nome_fantasia');

        if (info.nomeFantasia == null) info.nomeFantasia = info.razaoSocial;

        return info;
    }

    public class CNPJException extends Exception {}
}
