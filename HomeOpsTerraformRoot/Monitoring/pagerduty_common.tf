data "pagerduty_user" "primary_user" {
  email = var.pagerduty.primary_user_email
}
# there's limit on 1 escalation policy in free tier, so we use the default one
data "pagerduty_escalation_policy" "default" {
  name = "Default"
}
