module Data.Tickets exposing (..)


tickets =
    [ campTicket, couplesCampTicket, campfireTicket ]



-- @TODO need to use pricing IDs here, not product IDs
-- but how do we figure out the right price given the current user? Is there a Stripe API for that?


campTicket =
    { name = "Elm Camp Denmark 23 - Camp Ticket"
    , description = "Ticket for 1 Person including: on-site accommodation with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , stripeProductId = "prod_NWZ5JHXspU1l8p"
    }


couplesCampTicket =
    { name = "Elm Camp Denmark 23 - Couples Camp Ticket"
    , description = "Tickets for 2 people including: on-site accommodation for two people with private ensuite for 2 nights, breakfast, lunch, tea & dinners included."
    , stripeProductId = "prod_NWZ8FJ1Ckl9fIc"
    }


campfireTicket =
    { name = "Elm Camp Denmark 23 - Campfire Ticket"
    , description = "Ticket for 1 Person including: breakfast, lunch, tea & dinners included. Access to castle grounds. No accommodation included."
    , stripeProductId = "prod_NWZAQ3eQgK0XlF"
    }
