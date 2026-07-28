public class Application {
    
    // 1. De Unit of Work Fabriek
    // Hierin definieer je de VOLGORDE waarin Salesforce objecten moet inserten/updaten.
    // Dit voorkomt parent-child DML fouten (bv. eerst Account, dan Contact, dan Opportunity).

/**
    // BEGIN: Lege gestripte versie, omdat je anders de andere code niet kunt deployen
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(new List<SObjectType> { Account.SObjectType });

    public static final fflib_Application.ServiceFactory Service = 
        new fflib_Application.ServiceFactory(new Map<Type, Type>()); 

    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(new Map<Schema.SObjectType, Type>()); 

    // Oplossing: Voeg 'Application.Selector' toe als eerste parameter!
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(Application.Selector, new Map<Schema.SObjectType, Type>()); 

    // EINDE: Lege gestripte versie, omdat je anders de andere code niet kunt deployen
*/
     

    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                Account.SObjectType,
                Contact.SObjectType,
                Opportunity.SObjectType,
                Task.SObjectType
            }
        );

    // 2. De Service Fabriek (Mocht je Service-klassen gaan gebruiken)
    // UPDATE DE SERVICE FABRIEK:
    public static final fflib_Application.ServiceFactory Service = 
        new fflib_Application.ServiceFactory(
            new Map<Type, Type> {
                IAccountsService.class => AccountsServiceImpl.class
            }
        );


    // 3. De Selector Fabriek
    // HIER KOPPEL JE DE INTERFACE AAN DE ECHTE SELECTOR CLASS
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<Schema.SObjectType, Type> {
                Account.SObjectType => AccountsSelector.class
                // Voeg hier later andere objecten toe, bijv:
                // Contact.SObjectType => ContactsSelector.class
            }
        );

    // 4. De Domain Fabriek
    // HIER KOPPEL JE DE INTERFACE AAN DE ECHTE DOMAIN CLASS
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(
            Application.Selector,
            new Map<Schema.SObjectType, Type> {
                Account.SObjectType => Accounts.Constructor.class
            }
        );
        
}
