public with sharing class ContactTriggerHandler {
    public enum Operations{CREATE_CONTACT, DELETE_CONTACT}
    
    public static void checkContactUpdate(Map<Id, Contact> oldMap, List<Contact> triggerNew)
    {
        for(Contact c : triggerNew)
        {
            if(c.AccountId == null && oldMap.get(c.Id).AccountId != null)
            {
                c.AccountId.addError('Unable to remove account field value');
            }
            if(c.Email == null && c.Phone == null)
            {
                c.Email.addError('Please provide phone or email value');
                c.Phone.addError('Please provide phone or email value');
            }
        }
    }
    
    public static void createContactHistory(List<Contact> triggerContacts, Operations operation)
    {
        List<Contact_History__c> historyToInsert = new List<Contact_History__c>();
        for(Contact c : triggerContacts){
            Contact_History__c history = new Contact_History__c();
            if(operation==Operations.CREATE_CONTACT){
                history.Contact__c = c.Id;
                history.Name = 'Insert ';
                history.Action__c = 'Insert';
            }
            else{
                history.Name = 'Delete ';
                history.Action__c = 'Delete';
            }
            history.Name += c.Name + ' '+c.Id;
            history.Timestamp__c = System.now();
            historyToInsert.add(history);
        }
        insert historyToInsert;
    }
    
    
    public static void handleContactUpdate(List<Contact> triggerOldContacts, List<Contact> triggerNewContacts)
    {
        List<String> fieldsToCheck = new List<String>{'FirstName', 'LastName', 'Email', 'Phone', 'AccountId'};
        List<Contact_History__c> historicalContacts = new List<Contact_History__c>();
        for(Integer i=0; i<triggerOldContacts.size();i++)
        {
            Map<String, Object> old_values = triggerOldContacts[i].getPopulatedFieldsAsMap();
            Map<String, Object> new_values = triggerNewContacts[i].getPopulatedFieldsAsMap();
            List<String> different_fields = new List<String>();
            for(String fieldName: fieldsToCheck){
                if(old_values.get(fieldname) != new_values.get(fieldname)){
                    different_fields.add(fieldname);
                }
            }
            for(String field : different_fields){
                Contact_History__c c = new Contact_History__c();
                c.Contact__c=triggerOldContacts[i].Id;
                c.Name=triggerOldContacts[i].Name+' '+triggerOldContacts[i].Id+' Update';
                c.Action__c = 'Update';
                c.Timestamp__c = System.now();
                c.New_value__c = (String)new_values.get(field);
                c.Old_value__c = (String)old_values.get(field);
                c.Edited_field_name__c = field;
                historicalContacts.add(c);
            }
        }
        insert historicalContacts;
    }
}