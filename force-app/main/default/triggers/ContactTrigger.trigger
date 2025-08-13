// Remember about the good practices.
// Keep the logic in the handler class (ContactTriggerHandler), write only one trigger per object.
// Be sure that Your trigger handles bulk operations and please test the solution thoroughly
// by attempting various operations in Your org - changing account id field value on contacts, editing contacts.

trigger ContactTrigger on Contact (before update, after insert, after delete, after update) {
    // 1. Prevent user from saving any Contact which previously had AccountId field value and the value is being removed. The error message should be "Unable to remove account field value"
    // 2. Prevent user from saving any Contact without Email or Phone field (one of these has to be provided). The error message should be "Please provide phone or email value"
    if(Trigger.isBefore)
    {
        ContactTriggerHandler.checkContactUpdate(Trigger.oldMap, Trigger.new); 
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            ContactTriggerHandler.createContactHistory(Trigger.new, ContactTriggerHandler.Operations.CREATE_CONTACT);
        }
        else if(Trigger.isDelete){
            ContactTriggerHandler.createContactHistory(Trigger.old, ContactTriggerHandler.Operations.DELETE_CONTACT);
        }
        else if(Trigger.isUpdate)
        {
            ContactTriggerHandler.handleContactUpdate(Trigger.old, Trigger.new);
        }
    }
}