// port stripe_from_js : ({ msg : String, value : Json.Decode.Value } -> msg) -> Sub msg
// port stripe_to_js : Json.Value -> Cmd msg

exports.init = async function(app) {
    app.ports.stripe_to_js.subscribe(handlePortMessage);

    async function handlePortMessage(message) {
        let toElmMsg;
        // console.log(`Received msg from Elm: ${JSON.stringify(message)}`);
        switch(message.msg) {
            case 'loadCheckout':
                var stripeJs = document.createElement('script')
                stripeJs.type = 'text/javascript'
                stripeJs.src = 'https://js.stripe.com/v3/'
                stripeJs.onload = function() {

                  var stripe = Stripe(message.publicApiKey)

                  stripe.redirectToCheckout({
                    sessionId: message.id
                  }).then(function (result) {
                    console.log('Stripe error:', result)
                    // If `redirectToCheckout` fails due to a browser or network
                    // error, display the localized error message to your customer
                    // using `result.error.message`.
                  });
                }
                document.head.appendChild(stripeJs);
                break;
            default:
                console.log(`Couldn't find a handler for message: ${JSON.stringify(message)}`);
        }

        if(toElmMsg !== undefined) {
            // console.log('Sending message to Elm:', toElmMsg);
            app.ports.stripe_from_js.send(toElmMsg);
        }
    }
}
