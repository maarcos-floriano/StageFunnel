@isTest
global class HttpCNPJMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setStatusCode(200);
        res.setBody('{"razao_social":"Empresa Exemplo LTDA","fantasia":"Exemplo","cnpj":"12345678000199"}');
        return res;
    }
}
