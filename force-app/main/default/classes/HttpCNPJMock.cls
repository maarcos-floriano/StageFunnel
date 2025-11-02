@isTest
global class HttpCNPJMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setStatusCode(200);
        res.setBody('{"razao_social":"STAGE CONSULTING SERVIÇOS E CONSULTORIA EMPRESARIAL LTDA","fantasia":"Stage Consulting","cnpj":"44.605.692/0001-77"}');
        return res;
    }
}
