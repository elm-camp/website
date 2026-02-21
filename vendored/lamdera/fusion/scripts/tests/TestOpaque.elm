module TestOpaque exposing (testOpaque)

import Codegen.Parser
import Expect
import GenerationUtils
import String.Multiline
import Test exposing (Test)


testOpaque : Test
testOpaque =
    Test.skip <|
        Test.test "SeqDict" <| \_ ->
        case
            Codegen.Parser.parseFile
                { package = False
                , fullPath = "<test>"
                }
                source
        of
            Err e ->
                Expect.fail e.description

            Ok parsedFile ->
                GenerationUtils.testGenerationForFile
                    parsedFile
                    [ "" ]


source : String
source =
    String.Multiline.here
        """
        module SeqDict exposing (SeqDict)

        type SeqDict k v
            = SeqDict k v
        """
