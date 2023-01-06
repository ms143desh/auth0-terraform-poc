# export AUTH0_DOMAIN=dev-z4u5lwws.us.auth0.com
# export AUTH0_CLIENT_ID=wY4lT01jg5DGyG6zm2ES4v8jW9MeFymr
# export AUTH0_CLIENT_SECRET=xr5Q8LsOsbwDKxtwl0mzY64eFkec4C1Zg4ReKebodfM8eKTLDpYRmgOWVy1KvbIm

terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 0.34.0"
    }
  }
}

provider "auth0" {
  domain        = "dev-z4u5lwws.us.auth0.com"
  client_id     = "wY4lT01jg5DGyG6zm2ES4v8jW9MeFymr"
  client_secret = "xr5Q8LsOsbwDKxtwl0mzY64eFkec4C1Zg4ReKebodfM8eKTLDpYRmgOWVy1KvbIm"
  debug         = "true"
}

resource "auth0_client" "tf_poc_app_01" {
  name                                = "Terraform POC Application 01"
  description                         = "Terraform POC Application 01"
  app_type                            = "regular_web"
  custom_login_page_on                = true
  is_first_party                      = true
  is_token_endpoint_ip_header_trusted = false
  token_endpoint_auth_method          = "client_secret_post"
  oidc_conformant                     = true
  callbacks                           = ["http://localhost:3000/login/oauth2/code/auth0"]
  # allowed_origins                     = ["https://example.com"]
  allowed_logout_urls                 = ["http://localhost:3000"]
  # web_origins                         = ["https://example.com"]
  grant_types = [
    "authorization_code",
    # "http://auth0.com/oauth/grant-type/password-realm",
    "implicit",
    # "password",
    "refresh_token",
    "client_credentials"
  ]
  client_metadata = {
    app_type = "regular_app"
    product = "example_care"
  }

  jwt_configuration {
    lifetime_in_seconds = 300
    secret_encoded      = true
    alg                 = "RS256"
    /*
    scopes = {
      foo = "bar"
    }
    */
  }
/*
  refresh_token {
    leeway          = 0
    token_lifetime  = 2592000
    rotation_type   = "rotating"
    expiration_type = "expiring"
  }
*/
/*
  mobile {
    ios {
      team_id               = "9JA89QQLNQ"
      app_bundle_identifier = "com.my.bundle.id"
    }
  }
*/
/*
  addons {
    samlp {
      audience = "https://example.com/saml"
      mappings = {
        email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      }
      create_upn_claim                   = false
      passthrough_claims_with_no_mapping = false
      map_unknown_claims_as_is           = false
      map_identities                     = false
      name_identifier_format             = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      name_identifier_probes = [
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
      ]
      signing_cert = "-----BEGIN PUBLIC KEY-----\nMIGf...bpP/t3\n+JGNGIRMj1hF1rnb6QIDAQAB\n-----END PUBLIC KEY-----\n"

      signing_key {
        key  = "-----BEGIN PRIVATE KEY-----\nMIGf...bpP/t3\n+JGNGIRMj1hF1rnb6QIDAQAB\n-----END PUBLIC KEY-----\n"
        cert = "-----BEGIN PUBLIC KEY-----\nMIGf...bpP/t3\n+JGNGIRMj1hF1rnb6QIDAQAB\n-----END PUBLIC KEY-----\n"
      }
    }
  }
*/
native_social_login {
	apple {
		enabled = false
	}
	facebook {
		enabled = false
	}
  }
}

resource "auth0_connection" "tf_poc_connection_01" {
  name                 = "terraform-poc-connection"
  is_domain_connection = true
  strategy             = "auth0"
  metadata = {
    app_type = "auth0_db_connection"
    product = "example_care"
  }

  options {
    password_policy                = "excellent"
    brute_force_protection         = true
    # enabled_database_customization = true
    import_mode                    = false
    requires_username              = false
    disable_signup                 = false
    custom_scripts = {
      get_user = <<EOF
        function getByEmail(email, callback) {
          return callback(new Error("Whoops!"));
        }
      EOF
    }
    /*
    configuration = {
      foo = "bar"
      bar = "baz"
    }
    upstream_params = jsonencode({
      "screen_name" : {
        "alias" : "login_hint"
      }
    })

    password_history {
      enable = true
      size   = 3
    }

    password_no_personal_info {
      enable = true
    }

    password_dictionary {
      enable     = true
      dictionary = ["password", "admin", "1234"]
    }

    password_complexity_options {
      min_length = 12
    }

    validation {
      username {
        min = 10
        max = 40
      }
    }

    mfa {
      active                 = true
      return_enroll_settings = true
    }
    */
  }
  enabled_clients = [auth0_client.tf_poc_app_01.id]
}

resource "auth0_action" "tf_poc_custom_pre_registration_action" {
  name    = format("Terraform Custom Pre Registration Action %s", timestamp())
  runtime = "node12"
  deploy  = true
  code    = file("action_scripts/tf_poc_custom_pre_registration_action.js")

  supported_triggers {
    id      = "pre-user-registration"
    version = "v1"
  }
/*
  dependencies {
    name    = "lodash"
    version = "latest"
  }

  dependencies {
    name    = "request"
    version = "latest"
  }

  secrets {
    name  = "FOO"
    value = "Foo"
  }

  secrets {
    name  = "BAR"
    value = "Bar"
  }
*/
}

resource "auth0_trigger_binding" "tc_poc_custom_pre_registration_flow" {
  trigger = "pre-user-registration"

  actions {
    id           = auth0_action.tf_poc_custom_pre_registration_action.id
    display_name = auth0_action.tf_poc_custom_pre_registration_action.name
  }
/*
  actions {
    id           = auth0_action.action_bar.id
    display_name = auth0_action.action_bar.name
  }
*/
}

resource "auth0_action" "tf_poc_custom_post_registration_action" {
  name    = format("Terraform Custom Post Registration Action %s", timestamp())
  runtime = "node12"
  deploy  = true
  code    = file("action_scripts/tf_poc_custom_post_registration_action.js")

  supported_triggers {
    id      = "post-user-registration"
    version = "v1"
  }
/*
  dependencies {
    name    = "lodash"
    version = "latest"
  }

  dependencies {
    name    = "request"
    version = "latest"
  }

  secrets {
    name  = "FOO"
    value = "Foo"
  }

  secrets {
    name  = "BAR"
    value = "Bar"
  }
*/
}

resource "auth0_trigger_binding" "tc_poc_custom_post_registration_flow" {
  trigger = "post-user-registration"

  actions {
    id           = auth0_action.tf_poc_custom_post_registration_action.id
    display_name = auth0_action.tf_poc_custom_post_registration_action.name
  }
/*
  actions {
    id           = auth0_action.action_bar.id
    display_name = auth0_action.action_bar.name
  }
*/
}

resource "auth0_action" "tf_poc_custom_post_login_action" {
  name    = format("Terraform Custom Post Login Action %s", timestamp())
  runtime = "node12"
  deploy  = true
  code    = file("action_scripts/tf_poc_custom_post_login_action.js")

  supported_triggers {
    id      = "post-login"
    version = "v1"
  }
/*
  dependencies {
    name    = "lodash"
    version = "latest"
  }

  dependencies {
    name    = "request"
    version = "latest"
  }

  secrets {
    name  = "FOO"
    value = "Foo"
  }

  secrets {
    name  = "BAR"
    value = "Bar"
  }
*/
}

resource "auth0_trigger_binding" "tc_poc_custom_post_login_flow" {
  trigger = "post-login"

  actions {
    id           = auth0_action.tf_poc_custom_post_login_action.id
    display_name = auth0_action.tf_poc_custom_post_login_action.name
  }
/*
  actions {
    id           = auth0_action.action_bar.id
    display_name = auth0_action.action_bar.name
  }
*/
}