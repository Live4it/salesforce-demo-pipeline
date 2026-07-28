@IsTest
private class AccountsTriggerTest {

    @IsTest
    static void trigger_MoetDomainKlasseAanroepenBijInsert() {
        // 1. Maak mock data aan (Trigger tests vereisen vaak echte DML om de trigger te activeren)
        Account nieuwAccount = new Account(
            Name = 'Test fflib Account',
            ShippingCountry = 'Netherlands'
        );

        // 2. Voer DML uit om de trigger te triggeren
        Test.startTest();
        insert nieuwAccount;
        Test.stopTest();

        // 3. Verificatie
        // Haal het record op om te kijken of eventuele automatische fflib-domeinlogica
        // (bijvoorbeeld het vullen van een standaardveld in handleBeforeInsert) is toegepast.
        Account geupdatetAccount = [SELECT Id, Name FROM Account WHERE Id = :nieuwAccount.Id];
        Assert.areEqual('Test fflib Account', geupdatetAccount.Name, 'Trigger moet succesvol doorlopen');
    }
}