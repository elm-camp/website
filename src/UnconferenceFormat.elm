module UnconferenceFormat exposing (view)

import Helpers
import RichText exposing (Inline(..), RichText(..))


view : List RichText
view =
    [ Section "Unconference Format"
        [ Section "First and foremost, there are no unchangeable rules, with the exception of the \"rule of two feet\":"
            [ Paragraph [ Text "It is expected that people move freely between sessions at any time. If you are no longer interested in listening or contributing to the conversation, find another one." ]
            ]
        , QuoteBlock [ Text "You know how at a conference, the best discussions often occur when people are relaxed during coffee breaks? That's the whole idea of an unconference: it's like a long, informal coffee break where everyone can contribute to the conversation. The participants drive the agenda. Any structure that exists at an unconference is just there to kick things off and to help the conversations flow smoothly, not to restrict or dictate the topics." ]
        , Section "We are doing this together."
            [ Paragraph [ Text "The following is intended as a collective starting point." ]
            ]
        , Section "Plan"
            [ BulletList
                [ Bold "Before Elm Camp" ]
                [ Paragraph
                    [ Text "People can start proposing presentations before Elm camp in Elmcraft Discord: "
                    , ExternalLink "#elm-camp-26" Helpers.discordInviteLink
                    , Text " which is a place for conversations before, during and after the camp. You can also use this channel to coordinate travel plans."
                    ]
                , Paragraph [ Text "There are no pre-planned sessions." ]
                , Paragraph [ Text "We'll start with 2 tracks. If needed, more concurrent sessions may be scheduled during the unconference." ]
                , Paragraph [ Text "Sessions will be offered in 30 minute and 1 hour blocks." ]
                , Paragraph [ Text "We encourage attendees to think about how they might like to document or share our discussions with the community after Elm Camp. e.g. blog posts, graphics, videos" ]
                ]
            , BulletList
                [ Bold "During Elm Camp" ]
                [ Paragraph [ Text "We'll arrange collective scheduling sessions every morning, where together we pitch, vote for and schedule sessions." ]
                , Paragraph [ Text "All tracks will run in sync to allow for easy switching between sessions." ]
                , Paragraph [ Text "We'll have reserved time for public announcements. You'll have a couple minutes on stage if needed." ]
                , Paragraph [ Text "The schedule will be clearly displayed at the venue for easy reference." ]
                , Paragraph [ Text "Session locations will have distinctive names for effortless navigation." ]
                , Paragraph [ Text "Session endings will be made clear to prevent overruns." ]
                , Paragraph [ Text "Doors will be kept open to make moving along easy." ]
                , Paragraph [ Text "Breaks are scheduled to provide downtime." ]
                , Paragraph [ Text "The organisers will be readily available and identifiable for any assistance needed." ]
                ]
            ]
        , Section "Guidelines"
            [ BulletList
                [ Bold "Be inclusive" ]
                [ Paragraph [ Text "There is no restriction or theme on the subject for proposed topics, except that they should be with positive intent. Think do no harm and don't frame your session negatively. A simple, open question is best." ]
                , Paragraph [ Text "If you want to talk about something and someone here wants to talk with you about it, grab some space and make it happen. You don't need permission, but keep it open to everyone and don't disrupt running sessions." ]
                , Paragraph [ Text "Think of it as a gathering of people having open conversations" ]
                , Paragraph
                    [ Text "Think discussion: talk "
                    , Italic "with"
                    , Text ", not talk "
                    , Italic "at"
                    , Text ". Share a 20-second description of what you think would be interesting to talk about and why."
                    ]
                , Paragraph [ Text "As much as possible, the organisers want to be normal session participants. We're one of you." ]
                , Paragraph [ Text "People will be freely moving in and out of sessions. If you find yourself in an empty room, migrate." ]
                , Paragraph [ Text "The event has some fixed infrastructure to keep the environment positive. But outside of that if you want to change something, feel free to make it happen." ]
                ]
            ]
        , Section "What happens here, stays here, by default."
            [ Paragraph [ Text "Assume people are comfortable saying stuff here because it's not going on twitter, so if you do want to quote someone during or after Elm Camp, please get their permission." ]
            , Paragraph [ Text "Any outputs from the event should focus on the ideas, initiatives and projects discussed, as opposed to personal opinons or statements by individuals." ]
            ]
        ]
    ]
