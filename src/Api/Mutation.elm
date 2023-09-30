-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Mutation exposing (..)

import Api.InputObject
import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)


type alias CreateQuestionOptionalArguments =
    { condition : OptionalArgument Api.InputObject.ModelQuestionConditionInput }


type alias CreateQuestionRequiredArguments =
    { input : Api.InputObject.CreateQuestionInput }


createQuestion :
    (CreateQuestionOptionalArguments -> CreateQuestionOptionalArguments)
    -> CreateQuestionRequiredArguments
    -> SelectionSet decodesTo Api.Object.Question
    -> SelectionSet (Maybe decodesTo) RootMutation
createQuestion fillInOptionals____ requiredArgs____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { condition = Absent }

        optionalArgs____ =
            [ Argument.optional "condition" filledInOptionals____.condition Api.InputObject.encodeModelQuestionConditionInput ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "createQuestion" (optionalArgs____ ++ [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeCreateQuestionInput ]) object____ (Basics.identity >> Decode.nullable)


type alias UpdateQuestionOptionalArguments =
    { condition : OptionalArgument Api.InputObject.ModelQuestionConditionInput }


type alias UpdateQuestionRequiredArguments =
    { input : Api.InputObject.UpdateQuestionInput }


updateQuestion :
    (UpdateQuestionOptionalArguments -> UpdateQuestionOptionalArguments)
    -> UpdateQuestionRequiredArguments
    -> SelectionSet decodesTo Api.Object.Question
    -> SelectionSet (Maybe decodesTo) RootMutation
updateQuestion fillInOptionals____ requiredArgs____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { condition = Absent }

        optionalArgs____ =
            [ Argument.optional "condition" filledInOptionals____.condition Api.InputObject.encodeModelQuestionConditionInput ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "updateQuestion" (optionalArgs____ ++ [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeUpdateQuestionInput ]) object____ (Basics.identity >> Decode.nullable)


type alias DeleteQuestionOptionalArguments =
    { condition : OptionalArgument Api.InputObject.ModelQuestionConditionInput }


type alias DeleteQuestionRequiredArguments =
    { input : Api.InputObject.DeleteQuestionInput }


deleteQuestion :
    (DeleteQuestionOptionalArguments -> DeleteQuestionOptionalArguments)
    -> DeleteQuestionRequiredArguments
    -> SelectionSet decodesTo Api.Object.Question
    -> SelectionSet (Maybe decodesTo) RootMutation
deleteQuestion fillInOptionals____ requiredArgs____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { condition = Absent }

        optionalArgs____ =
            [ Argument.optional "condition" filledInOptionals____.condition Api.InputObject.encodeModelQuestionConditionInput ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "deleteQuestion" (optionalArgs____ ++ [ Argument.required "input" requiredArgs____.input Api.InputObject.encodeDeleteQuestionInput ]) object____ (Basics.identity >> Decode.nullable)