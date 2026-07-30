public class AccountsSelector extends fflib_SObjectSelector implements IAccountsSelector {
    
    public static IAccountsSelector newInstance() {
        return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.ShippingCountry,
            Account.Name,
            Account.AnnualRevenue,
            Account.Description
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    // Specifieke methode voor onze User Story om accounts inclusief contacten op te halen
    public List<Account> selectByIdWithContacts(Set<Id> accountIds) {
        // 1. Start de basis query voor Account
        fflib_QueryFactory accountQueryFactory = newQueryFactory();
        
        // 2. Start de subquery context voor de child-relatie 'Contacts'
        // Dit lost de signature/void fout op!
        fflib_QueryFactory contactQueryFactory = accountQueryFactory.subselectQuery('Contacts');
        
        // 3. Voeg de specifieke Contact-velden toe aan de zojuist gemaakte subquery
        contactQueryFactory.selectFields(new List<Schema.SObjectField>{
            Contact.Id,
            Contact.MailingCountry,
            Contact.AccountId
        });
        
        // 4. Filter op de specifieke Account Ids en voer de query uit
        return (List<Account>) Database.query(
            accountQueryFactory.setCondition('Id IN :accountIds').toSOQL()
        );
    }

    public List<Account> selectById(Set<Id> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
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
            AccountId = fakeAccountId
            MailingCountry = null // Will be updated afterv test
        );

	// B. Prepare the child subselect structure for JSON
	Map<String, Object> subselectJson = new Map<String, Object>{
    	'totalSize' => 1,
    	'done' => true,
    	'records' => new List<Contact>{ childContact }

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
        System.assertEquals('Netherlands', childContact.MailingCountry, 'De Mailingcountry had Netherlands moeten zijn.');
        
        // 9. Verificatie via Apex Mocks: Is registerDirty en commitWork daadwerkelijk aangeroepen?
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(mockedAccountsWithChildren[0]);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }


}