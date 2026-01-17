module Camp26Czech.Artifacts exposing (view)

import MarkdownThemed
import Ui
import Ui.Anim
import Ui.Layout
import Ui.Prose


view : a -> Ui.Element msg
view _ =
    """

# Artifacts
After conference contributed artifacts will be posted here.

"""
        |> MarkdownThemed.renderFull
