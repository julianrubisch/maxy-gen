Feature: MaxyGen
  Scenario: It responds with a blank patch when --blank is specified
    When I run `maxy-gen generate --blank`
    Then the output should contain "patcher"

  Scenario: It responds with a patch when I generate a simple chain
    When I run `maxy-gen generate 'cycle~-ezdac~'`
    Then the output should contain "newobj"