public with sharing class ContactTriggerHandler {
    public static void handleAccountIdDelete()
    {
        
    }
    
    public static void handleBlankFields()
    {
        
    }
    
    public static void handleContactCreate(List<Contact> triggerNewContacts)
    {
        List<Contact> contactsToInsert = new List<Contact>();
        for(Contact c : triggerNewContacts){
            Contact history_contact = new Contact(
                Contact = triggerNewContacts.Id,
            History_name__c = 'Insert '+triggerNewContacts.Name+' '+triggerNewContacts.Id,
            Action__c = 'Insert',
            Timestamp__c = System.now()
                );
            contactsToInsert.add(history_contact);
        }
        insert contactsToInsert;
    }
    
    public static void handleContactDelete(List<Contact> triggerOldContacts)
    {
        List<Contact> contactsToInsert = new List<Contact>();
        for(Contact c : triggerOldContacts){
            Contact history_contact = new Contact(
                History_name__c = 'Delete '+triggerOldContacts.Name+' '+triggerOldContacts.Id,
            Action__c = 'Delete',
            Timestamp__c = System.now()
                );
            contactsToInsert.add(history_contact);
        }
        insert contactsToInsert;
    }
    
    public static void handleContactUpdate(List<Contact> triggerOldContacts, List<Contact> triggerNewContacts)
    {
        List<String> fieldsToCheck = new List<String>{'FirstName', 'LastName', 'Email', 'Phone', 'AccoundId'};
        List<Contact> historicalContacts = new List<Contact>();
        for(Integer i=0; i<triggerOldContacts.size();i++)
        {
            Map<String, Object> old_values = triggerOldContacts[i].getPopulatedFieldsAsMap();
            Map<String, Object> new_values = triggerNewContacts[i].getPopulatedFieldsAsMap();
            List<String> different_fields = new List<String>();
            for(String fieldName: fieldsToCheck){
                if(old_values[i].get(fieldname) != new_values[i].get(fieldname)){
                    different_fields.add(fieldname);
                }
            }
            for(String field : different_fields){
                Contact c = new Contact(
                    Contact=triggerOldContacts[i].Id,
                    Name=triggerOldContacts[i].Name+' '+triggerOldContacts[i].Id+' Update',
                    Action__c = 'Update',
                    Timestamp__c = System.now(),
                    NewValue__c = new_values.get(field),
                    OldValue__c = old_values.get(field),
                    EditedField__c = field
                );
                historicalContacts.add(c);
            }
        }
        insert historicalContacts;
    }
}