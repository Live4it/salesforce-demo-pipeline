public with sharing class AccountsController {

    /**
     * 1A. Invocable Methode voor Salesforce Flows
     * Flows sturen altijd een List van inputs (omdat Flows bulk-proof werken).
     */
    @InvocableMethod(
        label='Sync Account Land naar Contacten' 
        description='Kopieert het ShippingCountry van de geselecteerde Accounts naar het MailingCountry van alle gerelateerde Contacten.'
        category='Account'
    )
    public static void syncCountryFromFlow(List<Id> accountIds) {
        if (accountIds != null && !accountIds.isEmpty()) {
            // Vertaal de List naar een Set en roep de service aan
            AccountsService.syncMailingCountryToContacts(new Set<Id>(accountIds));
        }
    }

    /**
     * 1B. AuraEnabled Methode voor Lightning Web Components (LWC)
     * Kan vanuit Javascript aangeroepen worden met een specifiek Account ID.
     */
    @AuraEnabled
    public static void syncCountryFromLwc(Id accountId) {
        try {
            if (accountId != null) {
                AccountsService.syncMailingCountryToContacts(new Set<Id>{ accountId });
            }
        } catch (Exception e) {
            // Zorg dat de foutmelding netjes aankomt in de LWC Javascript catch-block
            throw new AuraHandledException('Fout tijdens synchroniseren: ' + e.getMessage());
        }
    }
}
