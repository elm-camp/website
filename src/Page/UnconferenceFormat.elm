module Page.UnconferenceFormat exposing (..)

import Element exposing (..)
import MarkdownThemed


view : Element msg
view =
    """
# Unconference Format

## First and foremost, there are no unchangeable rules, with the exception of the "rule of two feet":
### It is expected that people move freely between sessions at any time. If you are no longer interested in listening or contributing to the conversation, find another one.

<br/>

> <br/>
> You know how at a conference, the best discussions often occur when people are relaxed during coffee breaks? That's the whole idea of an unconference: it's like a long, informal coffee break where everyone can contribute to the conversation. The participants drive the agenda. Any structure that exists at an unconference is just there to kick things off and to help the conversations flow smoothly, not to restrict or dictate the topics.

<br/>
<br/>

## We are doing this together.
## The following is intended as a collective starting point.

# Plan

## Before Elm Camp

- People can start proposing presentations before Elm camp in the form of cards on a Trello board which will be a place for conversations and serve as a schedule during the unconference and an archive after.
- There are 2 pre-planned sessions (the unkeynotes at the start and end of Elm Camp)
- We'll start with 3 tracks. If needed, more concurrent sessions may be scheduled during the unconference.
- Sessions will be offered in 15 and 30 minute blocks.
- We encourage attendees to think about how they might like to document or share our discussions with the community after Elm Camp. e.g. blog posts, graphics, videos

## During Elm Camp

- We'll arrange collective scheduling sessions every morning, where together we pitch, vote for and schedule sessions.
- All tracks will run in sync to allow for easy switching between sessions.
- We'll have reserved time for public announcements. You'll have a couple minutes on stage if needed.
- The schedule will be clearly displayed both online and at the venue for easy reference.
- Session locations will have distinctive names for effortless navigation.
- Session endings will be made clear to prevent overruns.
- Doors will be kept open to make moving along easy.
- Breaks are scheduled to provide downtime.
- The organisers will be readily available and identifiable for any assistance needed.

# Guidelines

## Be inclusive

- There is no restriction or theme on the subject for proposed topics, except that they should be with positive intent. Think do no harm and don't frame your session negatively. A simple, open question is best.
- If you want to talk about something and someone here wants to talk with you about it, grab some space and make it happen. You don't need permission, but keep it open to everyone and don't disrupt running sessions.
- Think of it as a gathering of people having open conversations
- Think discussion: talk _with_, not talk _at_. Share a 20-second description of what you think would be interesting to talk about and why.
- As much as possible, the organisers want to be normal session participants. We're one of you.
- People will be freely moving in and out of sessions. If you find yourself in an empty room, migrate.
- The event has some fixed infrastructure to keep the environment positive. But outside of that if you want to change something, feel free to make it happen.

## What happens here, stays here, by default.

- Assume people are comfortable saying stuff here because it's not going on twitter, so if you do want to quote someone during or after Elm Camp, please get their permission.
- Any outputs from the event should focus on the ideas, initiatives and projects discussed, as opposed to personal opinons or statements by individuals.
    """
        |> MarkdownThemed.renderFull
