@IsTest
private class AccountsTest {

    @IsTest
    static void wanneerShippingCountryWijzigtMoetServiceWordenAangeroepen() {
        // 1. Initialiseer de ApexMocks context
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // 2. Genereer een nep-Id voor het Account (voorkomt database DML)
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);

        // 3. Bouw de testdata op in het geheugen
        Account oudAccount = new Account(Id = accId, ShippingCountry = 'Nederland');
        Account nieuwAccount = new Account(Id = accId, ShippingCountry = 'Duitsland');

        // 4. Mock de Service-laag (We willen NIET dat de echte service-code gaat draaien!)
        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);

        // Koppel de service-mock aan de Application fabriek
        Application.Service.setMock(IAccountsService.class, serviceMock);

        // 5. Voer de Domain-methode handmatig uit (Simuleer het Trigger 'after update' event)
        Accounts domain = new Accounts(new List<Account>{ nieuwAccount });
        domain.onAfterUpdate(new Map<Id, Account>{ accId => oudAccount });

        // 6. VERIFICATIE (Assert middels ApexMocks)
        // We controleren of de methode 'syncMailingCountryToContacts' op de Service exact 1 keer is aangeroepen
        // én of deze is aangeroepen met een Set die exact ons 'accId' bevat.
        ((IAccountsService) mocks.verify(serviceMock, 1))
            .syncMailingCountryToContacts(new Set<Id>{ accId });
    }

    @IsTest
    static void wanneerShippingCountryNietWijzigtMagServiceNietWordenAangeroepen() {
        // 1. Initialiseer de ApexMocks context
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Id accId = fflib_IDGenerator.generate(Account.SObjectType);

        // 2. Bouw data op waarbij het land GEEN wijziging heeft
        Account oudAccount = new Account(Id = accId, ShippingCountry = 'Nederland');
        Account nieuwAccount = new Account(Id = accId, ShippingCountry = 'Nederland'); // Gelijk gebleven

        // 3. Mock de Service-laag
        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        Application.Service.setMock(IAccountsService.class, serviceMock);

        // 4. Voer de Domain-methode uit
        Accounts domain = new Accounts(new List<Account>{ nieuwAccount });
        domain.onAfterUpdate(new Map<Id, Account>{ accId => oudAccount });

        // 5. VERIFICATIE
        // We verifiëren met 'mocks.never()' (of 0 keer) dat de service NIET is aangeroepen
        ((IAccountsService) mocks.verify(serviceMock, mocks.never()))
            .syncMailingCountryToContacts(new Set<Id>{ accId });
    }

 @IsTest
    static void testEvaluateVipStatus_WithHighRevenue_ShouldSetDescription() {
        // 1. Setup Mock voor de Unit of Work (omdat het domain records registreert in de UOW)
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        
        // 2. Maak testdata aan in het geheugen (geen DML!)
        Account highRevenueAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            AnnualRevenue = 1200000,
            Description = ''
        );
        
        // 3. Instantieer de Domain klasse met de testdata
        Accounts domain = new Accounts(new List<Account>{ highRevenueAccount });

        // 4. Voer de methode uit
        Test.startTest();
        domain.evaluateVipStatus(uowMock);
        Test.stopTest();

        // 5. Assert: Is de omschrijving in het geheugen aangepast?
        System.assertEquals('VIP Account - Prioriteit Behandeling', highRevenueAccount.Description);
        
        // 6. Assert: Is het record geregistreerd bij de Unit of Work?
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(highRevenueAccount);
    }

    @IsTest
    static void testEvaluateVipStatus_WithLowRevenue_ShouldNotChangeDescription() {
        // 1. Setup Mock voor de Unit of Work
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        
        // 2. Maak testdata aan met te lage omzet
        Account lowRevenueAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            AnnualRevenue = 500000, // Te laag voor VIP
            Description = 'Originele Omschrijving'
        );
        
        // 3. Instantieer de Domain klasse
        Accounts domain = new Accounts(new List<Account>{ lowRevenueAccount });

        // 4. Voer de methode uit
        Test.startTest();
        domain.evaluateVipStatus(uowMock);
        Test.stopTest();

        // 5. Asserts: De omschrijving mag NIET veranderd zijn
        System.assertEquals('Originele Omschrijving', lowRevenueAccount.Description, 'De omschrijving had niet mogen veranderen.');
        
        // 6. Verifieer met Apex Mocks dat registerDirty NOOIT (0 keer) is aangeroepen
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).registerDirty(lowRevenueAccount);
    }   

}