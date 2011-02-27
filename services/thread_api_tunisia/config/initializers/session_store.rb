# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_thread_api_session',
  :secret      => '148ccd6b0c7a77dc9e3a3cb13fd78b6d2e4cd78c17886836e9e0474b889c9e2d000599a50f817e1f020cd80d54ed1ac70ca908d94d3c95bc1f8bce02f3cab936'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
