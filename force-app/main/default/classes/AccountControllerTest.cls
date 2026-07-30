// AccountControllerTest.cls
@IsTest
private class AccountControllerTest {

    @IsTest
    static void testProcessVipStatus_ShouldCallServiceWithCorrectId() {
        // 1. Setup Mock
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsService serviceMock = (IAccountsService) mocks.mock(AccountsServiceImpl.class);
        
        // 2. Injecteer de Service Mock in de Application fabriek
        Application.Service.setMock(IAccountsService.class, serviceMock);
        
        Id fakeAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        // 3. Voer de controller methode uit
        Test.startTest();
        AccountController.processVipStatus(fakeAccountId);
        Test.stopTest();

        // 4. Verifieer dat de service EXACT één keer is aangeroepen met het juiste ID
        ((IAccountsService) mocks.verify(serviceMock, 1)).updateVipStatus(new Set<Id>{ fakeAccountId });
    }

    @IsTest
    static void testProcessVipStatus_ExceptionThrown_ShouldThrowAuraHandledException() {
        // 1. Setup Mock
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsService serviceMock = (IAccountsService) mocks.mock(AccountsServiceImpl.class);
        
        // 2. Vertel de mock dat hij een fout moet werpen (met expliciete type casting naar IAccountsService)
        mocks.startStubbing();
        ((IAccountsService) mocks.doThrowWhen(
            new MathException('Simulated Service Error'), 
            serviceMock
        )).updateVipStatus((Set<Id>) fflib_Match.anyObject());
        mocks.stopStubbing();
        
        // 3. Injecteer de falende Service Mock
        Application.Service.setMock(IAccountsService.class, serviceMock);
        Id fakeAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        // 4. Voer de controller uit en vang de verwachte AuraHandledException op
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            AccountController.processVipStatus(fakeAccountId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        // 5. Verifieer dat de exception ook echt is afgegaan
        System.assert(exceptionThrown, 'De controller had een AuraHandledException moeten gooien.');
    }


}
