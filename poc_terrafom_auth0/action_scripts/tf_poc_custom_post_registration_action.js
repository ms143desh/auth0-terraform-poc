/**
* Handler that will be called during the execution of a PostUserRegistration flow.
*
* @param {Event} event - Details about the context and user that has registered.
*/
const axios = require("axios");
exports.onExecutePostUserRegistration = async (event) => {
  console.log("onExecutePostUserRegistration");
  console.log(event.user.email);
  console.log(event.user);
  console.log(event.secrets);

  //await axios.post("https://my-api.exampleco.com/users", { params: { email: event.user.email }});


};