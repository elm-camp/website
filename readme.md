## The Elm Camp website

https://elm.camp

Features:

- Static event info
- Dynamic inventory & ticket sales management
- Stripe integration

### Local development:

- [Install lamdera](https://dashboard.lamdera.app/docs/download)
- Run `lamdera live`

#### Troubleshooting
- To fix `resource busy (file is locked)` error, run `lamdera reset`

## Todos for tickets live
- [ ] Check ticket types and product ids
- [x] Update all places hardcoded to show GBP (£)
- [ ] Check maxAttendees = 80 is still correct
- [ ] Double check email confirmation messages
- [ ] Double check Sponsorship price display. Sponsorships have a product id, but they also have a .price. Should we show the
  price on the sponsorhip record or the price we have stored for the sponsorship's product id? See Sales.elm.
-- Are these necessary for tickets live?
- [ ] Update Venue and Access route info and uncomment the link in the footer or other places
- [ ] Update Grant contribution slider from GBP

## General todos