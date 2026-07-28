@IsTest
private class AccountsServiceTest {

    @IsTest
    static void syncMailingCountryToContacts_MoetMailingCountryAanpassenEnOpslaan() {
        // 1. Initialiseer de ApexMocks context
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // 2. Genereer nep-Ids om database DML te voorkomen
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);
        Id conId = fflib_IDGenerator.generate(Contact.SObjectType);

        // 3. Bouw de mock-data op die de selector normaal gesproken uit de database zou halen
        // We gebruiken de JSON-truc om de read-only child-relatie (Contacts) in het geheugen te vullen
        List<Account> mockAccountsMetContacten = (List<Account>) JSON.deserialize(
            '[{"Id":"' + accId + '", "ShippingCountry":"Spain", "Contacts":{"totalSize":1, "done":true, "records":[{"Id":"' + conId + '", "AccountId":"' + accId + '", "MailingCountry":"Netherlands"}]}}]',
            List<Account>.class
        );

        // 4. Maak de mocks aan voor de Selector en de Unit of Work
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        // Geef ApexMocks instructies (Stubbing)
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByIdWithContacts(new Set<Id>{ accId })).thenReturn(mockAccountsMetContacten);
        mocks.stopStubbing();

        // Koppel de mocks aan de Application fabriek zodat de runtime ze gebruikt
        Application.Selector.setMock(selectorMock);
        Application.UnitOfWork.setMock(uowMock);

        // 5. VOER DE SERVICE UIT
        Test.startTest();
        AccountsService.syncMailingCountryToContacts(new Set<Id>{ accId });
        Test.stopTest();

        // 6. VERIFICATIE
        // We verwachten dat het contact is aangepast naar 'Spanje' en is doorgegeven aan de UOW        
        // Controleer of registerDirty exact 1 keer is aangeroepen met het verwachte contact

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(
            fflib_Match.sObjectWith(
            new Map<Schema.SObjectField, Object>{
                Contact.Id => conId,
                Contact.MailingCountry => 'Spain'
            }
        )
    );
        
        // Controleer of commitWork exact 1 keer is aangeroepen om de transactie op te slaan
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
}
