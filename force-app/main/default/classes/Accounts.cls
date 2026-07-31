public class Accounts extends fflib_SObjectDomain implements IAccounts {
    
    public Accounts(List<Account> sObjectList) {
        super(sObjectList);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Accounts(sObjectList);
        }
    }

   public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        Set<Id> accountsWithChangedCountryIds = new Set<Id>();
        
        for (Account newAcc : (List<Account>) Records) {
            Account oldAcc = (Account) existingRecords.get(newAcc.Id);
            if (newAcc.ShippingCountry != oldAcc.ShippingCountry) {
                accountsWithChangedCountryIds.add(newAcc.Id);
            }
        }

        // Delegeer de daadwerkelijke actie naar de Service-laag
        if (!accountsWithChangedCountryIds.isEmpty()) {
            AccountsService.syncMailingCountryToContacts(accountsWithChangedCountryIds);
        }
    }

    public override void onBeforeInsert() {
        // In de trigger zelf hebben we geen UOW nodig, 
        // we passen de records direct in het geheugen aan.
        applyVipStatusLogic();
    }   


    // Interne helper methode voor de trigger (past records direct aan)
    private void applyVipStatusLogic() {
        for(Account acc : (List<Account>) getRecords()) {
            if(acc.AnnualRevenue >= 1000000) {
                acc.Description = 'VIP Account - Prioriteit Behandeling';
            }
        }
    }    

    // Onze business logica

    /* ---- Bestaande business logica voor de SERVICE-laag ---- */
    // De Service maakt de UOW aan en geeft deze hieraan mee.   
    public void evaluateVipStatus(fflib_ISObjectUnitOfWork uow) {
        for(Account acc : (List<Account>) getRecords()) {
            if(acc.AnnualRevenue >= 1000000) {
                acc.Description = 'VIP Account - Prioriteit Behandeling';
                uow.registerDirty(acc);
            }
        }
    }

    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        applyVipStatusLogic();
    }


}