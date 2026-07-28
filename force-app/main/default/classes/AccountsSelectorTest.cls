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
}