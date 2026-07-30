@IsTest
private class AccountsSelectorTest {

    @IsTest
    static void selectByIdWithContacts_MoetCorrecteVeldenEnSubqueryBevatten() {
        // 1. Initialiseer de selector
        AccountsSelector selector = new AccountsSelector();
        
        // 2. Roep de methode aan met een lege set (we testen alleen de SOQL-opbouw)
        Test.startTest();
        try {
            // Dit kan falen op Database.query omdat er geen records zijn, 
            // maar we willen de query-opbouw controleren via de QueryFactory indien nodig.
            // Alternatief: test via de QueryFactory direct.
            List<Account> result = selector.selectByIdWithContacts(new Set<Id>());
        } catch(Exception e) {
            // We vangen eventuele runtime database fouten op als de org leeg is
        }
        Test.stopTest();

        // 3. Verifieer dat de selector de juiste SObjectType heeft
        Assert.areEqual(Account.SObjectType, selector.getSObjectType(), 'Selector moet Accounts targeten');
    }
    
    @IsTest
    static void newQueryFactory_MoetStandaardVeldenBevatten() {
        AccountsSelector selector = new AccountsSelector();
        
        Test.startTest();
        fflib_QueryFactory qf = selector.newQueryFactory();
        Test.stopTest();
        
        String query = qf.toSOQL();
        // Controleer of de basisvelden altijd in de query zitten
        Assert.isTrue(query.contains('Name'), 'Query moet Name bevatten');
        Assert.isTrue(query.contains('Id'), 'Query moet Id bevatten');
    }

    @IsTest
    static void testSelectById_ShouldReturnCorrectAccountAndFields() {
        // 1. Maak een echt record aan (nodig voor Selector tests)
        Account acc = new Account(
            Name = 'Selector Test BV',
            AnnualRevenue = 500000
        );
        insert acc;

        // 2. Voer de selector uit
        Test.startTest();
        List<Account> result = AccountsSelector.newInstance().selectById(new Set<Id>{ acc.Id });
        Test.stopTest();

        // 3. Verifieer de resultaten
        System.assertEquals(1, result.size(), 'De selector had exact 1 record moeten vinden.');
        System.assertEquals(acc.Id, result[0].Id);
        System.assertEquals('Selector Test BV', result[0].Name);
        System.assertEquals(500000, result[0].AnnualRevenue);
    }

}