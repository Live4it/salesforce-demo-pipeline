// AccountsServiceImplTest.cls
@IsTest
private class AccountsServiceImplTest {

    @IsTest
    static void testUpdateVipStatus_WithHighRevenue_ShouldSetVipDescription() {
        // 1. Setup Mock Systeem
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // 2. Maak Mock objecten voor de lagen
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(AccountsSelector.class);
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        
        // 3. Genereer een nep ID (voorkomt DML)
        Id fakeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        
        // 4. Maak testdata in het geheugen
        Account mockAccount = new Account(
            Id = fakeAccountId,
            Name = 'Test Gigant BV',
            AnnualRevenue = 1500000, // Genoeg voor VIP
            Description = ''
        );
        List<Account> mockAccountList = new List<Account>{ mockAccount };

        // 5. Vertel de Selector Mock wat hij moet teruggeven als 'selectById' wordt aangeroepen
        /**
        mocks.startStubbing();
        ((IAccountsSelector) mocks.when(selectorMock.sObjectType())).thenReturn(Account.SObjectType);
        ((IAccountsSelector) mocks.when(selectorMock.selectById(new Set<Id>{ fakeAccountId }))).thenReturn(mockAccountList);
        // fflib_ApexMocks regelt het stoppen nu intern via de type-casting, 
        // dus we hebben mocks.endStubbing() of stopStubbing() hier niet meer nodig!

        */

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ fakeAccountId })).thenReturn(mockAccountList);
        mocks.stopStubbing();
        

        // 6. Injecteer de mocks in de Application fabriek
        Application.Selector.setMock(selectorMock);
        Application.UnitOfWork.setMock(uowMock);

        // 7. Voer de test uit
        Test.startTest();
        AccountsService.updateVipStatus(new Set<Id>{ fakeAccountId });
        Test.stopTest();

        // 8. Verificatie: Is de description aangepast?
        System.assertEquals('VIP Account - Prioriteit Behandeling', mockAccount.Description, 'De omschrijving had VIP moeten worden.');
        
        // 9. Verificatie via Apex Mocks: Is registerDirty en commitWork daadwerkelijk aangeroepen?
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(mockAccount);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @IsTest
    static void test_syncMailingCountryToContacts() {
        // 1. Setup Mock Systeem
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        // 2. Maak Mock objecten voor de lagen
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(AccountsSelector.class);
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
        
        // 3. Genereer een nep ID (voorkomt DML)
        Id fakeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id fakeContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        
        // The Selector returns a Account record with 1 child Contact record
	// We can't directly Assign it to the Contacts field, so we must create it in JSON and Deserialize it

	// A. Create your child records
        Contact childContact = new Contact(
            Id = fakeContactId,
            LastName = 'Test Gigant BV Contact',
            AccountId = fakeAccountId,
            MailingCountry = null // Will be updated afterv test
        );

	// B. Prepare the child subselect structure for JSON
	Map<String, Object> subselectJson = new Map<String, Object>{
    	'totalSize' => 1,
    	'done' => true,
    	'records' => new List<Contact>{ childContact }
    };

	// C. Prepare the parent record structure
	Map<String, Object> parentJson = new Map<String, Object>{
    	'Id' => fakeAccountId,
    	'Name' => 'Test Gigant BV',
	    'ShippingCountry' => 'Netherlands',
    	'Contacts' => subselectJson // Inject the subselect data into the relationship name
	};

	// D. Deserialize into the final typed SObject list
	List<Account> mockedAccountsWithChildren = (List<Account>) JSON.deserialize(
    	JSON.serialize(new List<Map<String, Object>>{ parentJson }), 
    	List<Account>.class
	);


        // 5. Vertel de Selector Mock wat hij moet teruggeven als 'selectByIdWithContacts' wordt aangeroepen


        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByIdWithContacts(new Set<Id>{ fakeAccountId })).thenReturn(mockedAccountsWithChildren);
        mocks.stopStubbing();
        

        // 6. Injecteer de mocks in de Application fabriek
        Application.Selector.setMock(selectorMock);
        Application.UnitOfWork.setMock(uowMock);

        // 7. Voer de test uit
        Test.startTest();
        AccountsService.syncMailingCountryToContacts(new Set<Id>{ fakeAccountId });
        Test.stopTest();

        // 8. Verificatie: Is de MailingCountry van Contact aangepast?
        System.assertEquals('Netherlands', mockedAccountsWithChildren[0].Contacts[0].MailingCountry, 'De Mailingcountry had Netherlands moeten zijn.');
        
        // 9. Verificatie via Apex Mocks: Is registerDirty en commitWork daadwerkelijk aangeroepen?
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(mockedAccountsWithChildren[0].Contacts[0]);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }



}
