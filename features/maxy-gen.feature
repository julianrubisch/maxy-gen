Feature: MaxyGen
  Scenario: It responds with a blank patch when --blank is specified
    When I run `maxy-gen generate --blank`
    Then the output should contain "blank"