module Camp26Czech.Artifacts exposing (view)

import Element exposing (Element)
import MarkdownThemed


view : a -> Element msg
view _ =
    """

# Artifacts
After conference contributed artifacts will be posted here.

"""
        |> MarkdownThemed.renderFull
