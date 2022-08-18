({
    doInit : function(component) {
        
        var action = component.get("c.getExpirationDaysLeft");

        action.setCallback(this, function(response) {

            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                
                var expDaysLeft = response.getReturnValue();
                component.set("v.daysLeft", "This trial org will expire in " + expDaysLeft + " days");
                
            } else if (component.isValid() && state === "ERROR") {
                component.set("v.daysLeft", response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    }
})