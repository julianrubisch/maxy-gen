Feature: MaxyGen
  Scenario: It responds with a blank patch when --blank is specified
    When I run `maxy-gen generate --blank`
    Then the output should contain "patcher"

  Scenario: It responds with a patch when I generate a simple chain
    When I run `maxy-gen generate 'cycle~-ezdac~'`
    Then the output should contain "newobj"

  Scenario: It responds with a patch when I specify mc.*/-/+ arithmetical operations
    When I run `maxy-gen generate 'mc.sig~{5.}-mc.+~{100}-mc.-~{50.}-mc./~{2}-mc.cycle~{440.}-mc.*~{0.1}'`
    Then the output should contain "newobj"
