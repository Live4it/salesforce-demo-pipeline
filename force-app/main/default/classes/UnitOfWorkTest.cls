@isTest
private class UnitOfWorkTest {

    @isTest 
    static void challengeComplete() {
        // Create the Unit of Work mapping the objects in dependency order
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Account.SObjectType,
                Contact.SObjectType,
                Note.SObjectType
            }
        );

        // Generate 100 Accounts, and for each Account, generate 5 Contacts and 5 Notes
        for (Integer i = 0; i < 100; i++) {
            Account acc = new Account(Name = 'Test Account ' + i);
            uow.registerNew(acc);

            for (Integer j = 0; j < 5; j++) {
                Contact cnt = new Contact(LastName = 'Test Contact ' + i + '_' + j);
                // Register the Contact and link it to the newly created Account
                uow.registerNew(cnt, Contact.AccountId, acc);

                Note nt = new Note(Title = 'Test Note ' + i + '_' + j, Body = 'Body content');
                // Register the Note and link it to the newly created Contact
                uow.registerNew(nt, Note.ParentId, cnt);
            }
        }

        // Commit all registered records and relationships to the database in a single transaction
        Test.startTest();
        uow.commitWork();
        Test.stopTest();

        // Required assertions to verify bulk creation worked as expected
        System.assertEquals(100, [SELECT Id FROM Account].size());
        System.assertEquals(500, [SELECT Id FROM Contact].size());
        System.assertEquals(500, [SELECT Id FROM Note].size());
    }
}