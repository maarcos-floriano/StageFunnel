@isTest
private class CNPJServiceTest {
    @isTest static void testFetchCNPJ() {
        Test.setMock(HttpCalloutMock.class, new HttpCNPJMock());
        CNPJService.CNPJInfo info = CNPJService.fetchCNPJ('44.605.692/0001-77');
        System.assertEquals('STAGE CONSULTING SERVIÇOS E CONSULTORIA EMPRESARIAL LTDA', info.razaoSocial);
        System.assertEquals('Stage Consulting', info.nomeFantasia);
    }
}