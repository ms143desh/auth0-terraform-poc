/**
* Handler that will be called during the execution of a PreUserRegistration flow.
*
* @param {Event} event - Details about the context and user that is attempting to register.
* @param {PreUserRegistrationAPI} api - Interface whose methods can be used to change the behavior of the signup.
*/
exports.onExecutePreUserRegistration = async (event, api) => {
  console.log(event.user.email);
  console.log("event.secrets");
  console.log(event.secrets);
  if (!event.user.email) {
    api.access.deny('Email not found in request', "emailNotFound");
    return;
  }
	// console.log(user.email);
  const whitelist = ['gmail.com','example.com', 'example.org']; //authorized domains
  const userHasAccess = whitelist.some(function (domain) {
    const emailSplit = event.user.email.split('@');
    // console.log(emailSplit);
    return emailSplit[emailSplit.length - 1].toLowerCase() === domain;
  });

  if (!userHasAccess) {
    api.access.deny('Email domain is invalid', "emailDomainInvalid");
    return;
  }
  
};
