// Remember about the good practices.
// Keep the logic in the handler class (ContactTriggerHandler), write only one trigger per object.
// Be sure that Your trigger handles bulk operations and please test the solution thoroughly
// by attempting various operations in Your org - changing account id field value on contacts, editing contacts.

trigger ContactTrigger on Contact (before insert, after insert, after delete, after update) {
    // 1. Prevent user from saving any Contact which previously had AccountId field value and the value is being removed. The error message should be "Unable to remove account field value"
    // 2. Prevent user from saving any Contact without Email or Phone field (one of these has to be provided). The error message should be "Please provide phone or email value"
    if(Trigger.isBefore)
    {
        Map<Id, Contact> m = new Map<Id, Contact>(Trigger.old);
        for(Contact c : Trigger.new)
        {
            if(c.AccountId == null && m.get(c.Id).AccountId != null)
            {
                ContactTriggerHandler.handleAccountIdDelete();
            }
            if(c.Email == null && c.Phone == null)
            {
                ContactTriggerHandler.handleBlankFields();
            }
        }
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            ContactTriggerHandler.handleContactCreate(Trigger.new);
        }
        else if(Trigger.isDelete){
            ContactTriggerHandler.handleContactDelete(Trigger.old);
        }
        else if(Trigger.isUpdate)
        {
            ContactTriggerHandler.handleContactUpdate(Trigger.old, Trigger.new);
        }
    }
}