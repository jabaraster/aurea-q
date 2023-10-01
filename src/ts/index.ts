import { Elm } from "../../.elm-spa/defaults/Main.elm";
import awsConfig from "../aws-exports";
import * as Auth from "./amplify-auth";
import { Amplify } from "aws-amplify";
import registerSubscriber from "./register-subscriber";
import "bulma/css/bulma.min.css";
import * as uuid from "uuid";
Amplify.configure(awsConfig);

const flags = {
    graphqlEndpoint: awsConfig.aws_appsync_graphqlEndpoint,
    apiKey: awsConfig.aws_appsync_apiKey,
    user: null,
};

const iniitializePorts = (ports) => {
    registerSubscriber(ports, "getContributorId", () => {
        const KEY ="contributor-id";
        let id = localStorage.getItem(KEY);
        if (!id) {
           id = uuid.v4(); 
           localStorage.setItem(KEY, id!);
        }
        ports.gotContributorId.send(id);
    });
};

window.addEventListener("load", () => {

    Auth.currentAuthenticatedUser()
        .then((user) => {
            console.log(user);
            flags.user = user;
            const elmApp = Elm.Main.init({
                flags: flags
            });
            iniitializePorts(elmApp.ports);
            Auth.iniitializePorts(elmApp);
        })
        .catch((err) => {
            console.log(err);
            const elmApp = Elm.Main.init({
                flags: flags
            });
            iniitializePorts(elmApp.port);
            Auth.iniitializePorts(elmApp);
        })
        ;
});
