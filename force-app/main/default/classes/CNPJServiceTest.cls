@isTest
private class CNPJServiceTest {
    @isTest static void testFetchCNPJ() {
        Test.setMock(HttpCalloutMock.class, new HttpCNPJMock());
        CNPJService.CNPJInfo info = CNPJService.fetchCNPJ('12.345.678/0001-99');
        System.assertEquals('Empresa Exemplo LTDA', info.razaoSocial);
        System.assertEquals('Exemplo', info.nomeFantasia);
    }
}
