import { Elm } from "../../.elm-spa/defaults/Main.elm";
import awsConfig from "../aws-exports";
import * as Auth from "./amplify-auth";
import { Amplify ,API, graphqlOperation } from "aws-amplify";
import registerSubscriber from "./register-subscriber";
import "bulma/css/bulma.min.css";
import * as uuid from "uuid";
import { GraphQLSubscription } from "@aws-amplify/api";
import * as subscriptions from "../graphql/subscriptions";
import { OnCreateQuestionSubscription } from "./api";
Amplify.configure(awsConfig);

const flags = {
    graphqlEndpoint: awsConfig.aws_appsync_graphqlEndpoint,
    apiKey: awsConfig.aws_appsync_apiKey,
    user: null,
};

const initializePorts = (ports) => {
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

const initializeSubscription = (ports) => {
    console.log(ports);
    const sub = API.graphql<GraphQLSubscription<OnCreateQuestionSubscription>>(
        graphqlOperation(subscriptions.onCreateQuestion)
      ).subscribe({
        next: ({ provider, value }) => {
            ports.onCreateQuestion.send(value.data!.onCreateQuestion);
            console.log({ provider, value })
        },
        error: (error) => console.warn(error)
      });
      // Stop receiving data updates from the subscription
      // sub.unsubscribe();
};

const initialize = (flags) => {
    const elmApp = Elm.Main.init({
        flags: flags
    });
    initializePorts(elmApp.ports);
    initializeSubscription(elmApp.ports);
    Auth.iniitializePorts(elmApp);
};

window.addEventListener("load", () => {

    Auth.currentAuthenticatedUser()
        .then((user) => {
            console.log(user);
            flags.user = user;
            initialize(flags);
        })
        .catch((err) => {
            console.log(err);
            initialize(flags);
        })
        ;
});
